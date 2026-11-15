<template>
  <div class="home">
    <!-- Hero Section -->
    <div class="hero-section">
      <div class="hero-content">
        <h1 class="hero-title">
          <span class="gradient-text">连接精英</span>
          <span class="divider">·</span>
          <span class="gradient-text">成就未来</span>
        </h1>
        <p class="hero-subtitle">基于SSM的校园兼职系统，为您提供极致的求职招聘体验</p>
        
        <div class="hero-actions">
          <el-button class="cta-btn primary" size="large" @click="router.push('/positions')">
            立即探索 <el-icon><ArrowRight /></el-icon>
          </el-button>
          <el-button class="cta-btn secondary" size="large" @click="router.push('/companies')">
            浏览企业
          </el-button>
        </div>
      </div>
      
      <!-- Decorative Elements -->
      <div class="hero-orb orb-1"></div>
      <div class="hero-orb orb-2"></div>
    </div>

    <!-- Quick Access Cards -->
    <div class="quick-access-section">
      <div class="access-grid">
        <div class="glass-card access-card" @click="router.push('/positions')">
          <div class="card-icon gradient-1">
            <el-icon><Suitcase /></el-icon>
          </div>
          <h3>浏览职位</h3>
          <p>海量校招职位，智能匹配推荐</p>
          <div class="card-arrow"><el-icon><ArrowRight /></el-icon></div>
        </div>
        
        <div class="glass-card access-card" @click="router.push('/companies')">
          <div class="card-icon gradient-2">
            <el-icon><OfficeBuilding /></el-icon>
          </div>
          <h3>名企专区</h3>
          <p>汇聚顶尖企业，发现优质雇主</p>
          <div class="card-arrow"><el-icon><ArrowRight /></el-icon></div>
        </div>
        
        <div class="glass-card access-card" @click="handleResumeClick">
          <div class="card-icon gradient-3">
            <el-icon><Document /></el-icon>
          </div>
          <h3>我的简历</h3>
          <p>在线简历编辑，一键投递申请</p>
          <div class="card-arrow"><el-icon><ArrowRight /></el-icon></div>
        </div>
      </div>
    </div>

    <!-- Latest Positions -->
    <div class="content-section">
      <div class="section-header">
        <h2 class="section-title">最新机遇</h2>
        <el-button class="view-all-btn" text @click="router.push('/positions')">
          查看更多 <el-icon><ArrowRight /></el-icon>
        </el-button>
      </div>
      
      <div class="positions-grid" v-loading="positionsLoading">
        <div 
          v-for="position in latestPositions" 
          :key="position.id" 
          class="glass-card position-card"
          @click="router.push(`/position/detail/${position.id}`)"
        >
          <div class="card-header">
            <h3 class="pos-name">{{ position.positionName }}</h3>
            <span class="salary-tag">{{ formatSalary(position.salaryMin, position.salaryMax) }}</span>
          </div>
          
          <div class="company-row">
            <el-icon><OfficeBuilding /></el-icon>
            <span>{{ position.companyName }}</span>
          </div>
          
          <div class="tags-row">
            <span class="tag-item"><el-icon><Location /></el-icon> {{ position.workAddress || '地点不限' }}</span>
            <span class="tag-item"><el-icon><School /></el-icon> {{ position.educationRequirement || '学历不限' }}</span>
            <span class="tag-item"><el-icon><Timer /></el-icon> {{ formatPublishTime(position.createTime) }}</span>
          </div>
          
          <div class="card-hover-overlay">
            <span class="view-detail">查看详情</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'
import { ArrowRight, Suitcase, OfficeBuilding, Document, Location, School, Timer } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()

const latestPositions = ref([])
const positionsLoading = ref(false)

const handleResumeClick = () => {
  if (!userStore.isLoggedIn) {
    router.push('/login')
  } else if (userStore.isStudent) {
    router.push('/resume')
  } else {
    router.push('/profile')
  }
}

const fetchLatestPositions = () => {
  positionsLoading.value = true
  request.get('/position/page', {
    status: 1,
    currentPage: 1,
    size: 8,
    sortBy: 'createTime'
  }, {
    onSuccess: (res) => {
      latestPositions.value = res.records || []
    },
    onFinally: () => {
      positionsLoading.value = false
    }
  })
}

const formatSalary = (min, max) => {
  if (!min && !max) return '面议'
  if (min && max) return `${min}k-${max}k`
  if (min) return `${min}k+`
  return `${max}k以内`
}

const formatPublishTime = (dateTime) => {
  if (!dateTime) return ''
  const date = new Date(dateTime)
  const now = new Date()
  const diff = now - date
  if (diff < 86400000) return '今天'
  if (diff < 259200000) return '3天内'
  return `${date.getMonth() + 1}-${date.getDate()}`
}

onMounted(() => {
  fetchLatestPositions()
})
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.home {
  padding-bottom: 4rem;
}

// Hero Section
.hero-section {
  position: relative;
  text-align: center;
  padding: 6rem 2rem 4rem;
  margin-bottom: 2rem;
  
  .hero-content {
    position: relative;
    z-index: 2;
    max-width: 800px;
    margin: 0 auto;
  }
  
  .hero-title {
    font-size: 4rem;
    font-weight: 800;
    margin-bottom: 1.5rem;
    line-height: 1.2;
    
    .gradient-text {
      @include aurora-text;
    }
    
    .divider {
      color: map.get($theme, text-light);
      margin: 0 1rem;
      opacity: 0.5;
    }
  }
  
  .hero-subtitle {
    font-size: 1.25rem;
    color: map.get($theme, text-light);
    margin-bottom: 2.5rem;
  }
  
  .hero-actions {
    display: flex;
    gap: 1.5rem;
    justify-content: center;
    
    .cta-btn {
      height: 54px;
      padding: 0 2.5rem;
      border-radius: 27px;
      font-size: 1.1rem;
      font-weight: 600;
      transition: all 0.3s ease;
      
      &.primary {
        background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
        border: none;
        color: white;
        box-shadow: 0 10px 25px rgba(99, 102, 241, 0.3);
        
        &:hover {
          transform: translateY(-3px);
          box-shadow: 0 15px 35px rgba(99, 102, 241, 0.4);
        }
      }
      
      &.secondary {
        background: rgba(255, 255, 255, 0.8);
        border: 1px solid rgba(255, 255, 255, 0.5);
        color: map.get($theme, text-main);
        backdrop-filter: blur(10px);
        
        &:hover {
          background: white;
          color: map.get($theme, primary);
        }
      }
    }
  }
  
  .hero-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    z-index: 0;
    opacity: 0.6;
    animation: float-slow 10s ease-in-out infinite;
    
    &.orb-1 {
      top: -100px;
      left: 10%;
      width: 400px;
      height: 400px;
      background: rgba(99, 102, 241, 0.2);
    }
    
    &.orb-2 {
      bottom: -50px;
      right: 10%;
      width: 300px;
      height: 300px;
      background: rgba(236, 72, 153, 0.2);
      animation-delay: -5s;
    }
  }
}

// Quick Access
.quick-access-section {
  max-width: 1200px;
  margin: 0 auto 5rem;
  padding: 0 2rem;
  
  .access-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 2rem;
  }
  
  .access-card {
    @include glass-card;
    padding: 2.5rem;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    @include hover-lift;
    
    .card-icon {
      width: 64px;
      height: 64px;
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2rem;
      color: white;
      margin-bottom: 1.5rem;
      
      &.gradient-1 { background: linear-gradient(135deg, #6366f1, #8b5cf6); }
      &.gradient-2 { background: linear-gradient(135deg, #ec4899, #f43f5e); }
      &.gradient-3 { background: linear-gradient(135deg, #10b981, #059669); }
    }
    
    h3 {
      font-size: 1.4rem;
      color: map.get($theme, text-main);
      margin-bottom: 0.5rem;
    }
    
    p {
      color: map.get($theme, text-light);
      margin-bottom: 0;
    }
    
    .card-arrow {
      position: absolute;
      bottom: 2rem;
      right: 2rem;
      color: map.get($theme, text-light);
      opacity: 0;
      transform: translateX(-10px);
      transition: all 0.3s ease;
    }
    
    &:hover .card-arrow {
      opacity: 1;
      transform: translateX(0);
      color: map.get($theme, primary);
    }
  }
}

// Content Section
.content-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    
    .section-title {
      font-size: 1.8rem;
      font-weight: 700;
      color: map.get($theme, text-main);
      position: relative;
      padding-left: 1rem;
      
      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 4px;
        height: 24px;
        background: map.get($theme, primary);
        border-radius: 2px;
      }
    }
    
    .view-all-btn {
      color: map.get($theme, text-light);
      &:hover { color: map.get($theme, primary); }
    }
  }
  
  .positions-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1.5rem;
  }
  
  .position-card {
    @include glass-card;
    padding: 1.5rem;
    cursor: pointer;
    position: relative;
    border-radius: 16px;
    background: map.get($theme, card-gradient-1);
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-5px);
      background: map.get($theme, card-gradient-hover);
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
      
      .card-hover-overlay { opacity: 1; }
    }
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 1rem;
      
      .pos-name {
        font-size: 1.1rem;
        font-weight: 600;
        color: map.get($theme, text-main);
        line-height: 1.4;
        flex: 1;
        margin-right: 0.5rem;
      }
      
      .salary-tag {
        color: map.get($theme, primary);
        font-weight: 700;
        font-size: 1rem;
        white-space: nowrap;
      }
    }
    
    .company-row {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      color: map.get($theme, text-main);
      font-weight: 500;
      margin-bottom: 1rem;
      
      .el-icon { color: map.get($theme, text-light); }
    }
    
    .tags-row {
      display: flex;
      flex-wrap: wrap;
      gap: 0.8rem;
      
      .tag-item {
        font-size: 0.85rem;
        color: map.get($theme, text-light);
        display: flex;
        align-items: center;
        gap: 0.3rem;
        background: rgba(255, 255, 255, 0.5);
        padding: 2px 8px;
        border-radius: 6px;
      }
    }
    
    .card-hover-overlay {
      position: absolute;
      inset: 0;
      background: rgba(99, 102, 241, 0.05);
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.3s ease;
      
      .view-detail {
        background: white;
        color: map.get($theme, primary);
        padding: 0.5rem 1.5rem;
        border-radius: 20px;
        font-weight: 600;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
      }
    }
  }
}

// Responsive
@media (max-width: 1024px) {
  .hero-section .hero-title { font-size: 3rem; }
  .quick-access-section .access-grid { grid-template-columns: repeat(2, 1fr); }
  .content-section .positions-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .hero-section {
    padding: 4rem 1rem;
    .hero-title { font-size: 2.2rem; }
    .hero-actions { flex-direction: column; }
  }
  .quick-access-section .access-grid { grid-template-columns: 1fr; }
  .content-section .positions-grid { grid-template-columns: 1fr; }
}
</style>
