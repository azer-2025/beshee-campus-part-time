<template>
  <div class="dashboard-container">
    <!-- 欢迎区块 -->
    <div class="glass-card welcome-banner">
      <div class="welcome-content">
        <el-avatar :size="80" :src="avatarUrl" class="user-avatar">
          {{ userInfo?.name?.charAt(0) }}
        </el-avatar>
        <div class="welcome-text">
          <h2>欢迎回来，<span class="gradient-text">{{ userInfo?.name || userInfo?.username }}</span></h2>
          <p class="time-display">{{ currentTime }}</p>
          <div class="role-badge">
            <el-tag effect="dark" round class="role-tag">{{ roleLabel }}</el-tag>
          </div>
        </div>
      </div>
      <div class="banner-illustration">
        <el-icon class="bg-icon"><DataLine /></el-icon>
      </div>
    </div>

    <!-- 数据指标 -->
    <div class="stats-grid">
      <div class="glass-card stats-card accent-blue">
        <div class="stats-icon"><el-icon><User /></el-icon></div>
        <div class="stats-info">
          <span class="label">学生总数</span>
          <h3 class="number">{{ dashboardStats.totalStudents || 0 }}</h3>
        </div>
      </div>
      
      <div class="glass-card stats-card accent-pink">
        <div class="stats-icon"><el-icon><OfficeBuilding /></el-icon></div>
        <div class="stats-info">
          <span class="label">企业总数</span>
          <h3 class="number">{{ dashboardStats.totalCompanies || 0 }}</h3>
        </div>
      </div>
      
      <div class="glass-card stats-card accent-indigo">
        <div class="stats-icon"><el-icon><Suitcase /></el-icon></div>
        <div class="stats-info">
          <span class="label">职位总数</span>
          <h3 class="number">{{ dashboardStats.totalPositions || 0 }}</h3>
        </div>
      </div>
      
      <div class="glass-card stats-card accent-violet">
        <div class="stats-icon"><el-icon><Document /></el-icon></div>
        <div class="stats-info">
          <span class="label">申请总数</span>
          <h3 class="number">{{ dashboardStats.totalApplications || 0 }}</h3>
        </div>
      </div>
    </div>

    <!-- 图表区块 -->
    <div class="charts-grid">
      <div class="glass-card chart-container">
        <div class="chart-header">
          <h3 class="chart-title">申请趋势</h3>
          <el-tag size="small" effect="plain" round>近12个月</el-tag>
        </div>
        <div ref="trendChartRef" class="chart-box"></div>
      </div>
      
      <div class="glass-card chart-container">
        <div class="chart-header">
          <h3 class="chart-title">职位分布</h3>
          <el-tag size="small" effect="plain" round>行业占比</el-tag>
        </div>
        <div ref="categoryChartRef" class="chart-box"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import * as echarts from 'echarts'
import request from '@/utils/request'
import { User, OfficeBuilding, Suitcase, Document, DataLine } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
const baseAPI = import.meta.env.VITE_BASE_API || '/api'

// 图表引用
const trendChartRef = ref(null)
const categoryChartRef = ref(null)
let trendChart = null
let categoryChart = null

// 仪表盘数据
const dashboardStats = ref({
  totalStudents: 0,
  totalCompanies: 0,
  totalPositions: 0,
  totalApplications: 0,
  applicationTrend: {},
  positionCategories: {}
})

// 获取仪表盘数据
const fetchDashboardStats = async () => {
  request.get('/dashboard/stats', null, {
    onSuccess: (res) => {
      dashboardStats.value = res
      setTimeout(() => initCharts(), 100)
    }
  })
}

// 初始化图表
const initCharts = () => {
  const isDark = false // Default to light theme for now

  // Trend Chart
  if (trendChartRef.value) {
    if (trendChart) trendChart.dispose()
    trendChart = echarts.init(trendChartRef.value)
    const trendData = dashboardStats.value.applicationTrend || {}
    const dates = Object.keys(trendData).sort()
    const values = dates.map(date => trendData[date])

    trendChart.setOption({
      tooltip: { trigger: 'axis', backgroundColor: 'rgba(255,255,255,0.9)', borderRadius: 12, borderWidth: 0, shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.05)' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { 
        type: 'category', 
        data: dates, 
        axisLine: { lineStyle: { color: '#e5e7eb' } },
        axisLabel: { color: '#6b7280', fontSize: 11 }
      },
      yAxis: { 
        type: 'value', 
        splitLine: { lineStyle: { type: 'dashed', color: '#f3f4f6' } },
        axisLabel: { color: '#6b7280' }
      },
      series: [{
        name: '投递数',
        data: values,
        type: 'line',
        smooth: true,
        showSymbol: false,
        lineStyle: { width: 4, color: '#6366f1' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(99, 102, 241, 0.2)' },
            { offset: 1, color: 'rgba(99, 102, 241, 0)' }
          ])
        },
        itemStyle: { color: '#6366f1' }
      }]
    })
  }

  // Category Chart
  if (categoryChartRef.value) {
    if (categoryChart) categoryChart.dispose()
    categoryChart = echarts.init(categoryChartRef.value)
    const categoryData = dashboardStats.value.positionCategories || {}
    const categories = Object.entries(categoryData).map(([name, value]) => ({ name, value }))

    categoryChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0', icon: 'circle', itemWidth: 10, textStyle: { color: '#6b7280' } },
      series: [{
        type: 'pie',
        radius: ['50%', '75%'],
        center: ['50%', '45%'],
        avoidLabelOverlap: false,
        itemStyle: { borderRadius: 12, borderColor: '#fff', borderWidth: 4 },
        label: { show: false },
        emphasis: { label: { show: true, fontSize: 16, fontWeight: 'bold' } },
        data: categories,
        color: ['#6366f1', '#ec4899', '#8b5cf6', '#10b981', '#f59e0b', '#3b82f6']
      }]
    })
  }
}

const roleLabel = computed(() => {
  const roleMap = { 'ADMIN': '系统管理员', 'COMPANY': '企业用户', 'STUDENT': '学生用户' }
  return roleMap[userInfo.value?.roleCode] || '用户'
})

const avatarUrl = computed(() => userInfo.value?.avatar ? baseAPI + userInfo.value.avatar : '')

const currentTime = ref('')
let timeInterval = null
const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleDateString('zh-CN', { 
    year: 'numeric', month: 'long', day: 'numeric', weekday: 'long', 
    hour: '2-digit', minute: '2-digit' 
  })
}

const handleResize = () => {
  trendChart?.resize()
  categoryChart?.resize()
}

onMounted(() => {
  updateTime()
  timeInterval = setInterval(updateTime, 1000)
  fetchDashboardStats()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (timeInterval) clearInterval(timeInterval)
  window.removeEventListener('resize', handleResize)
  trendChart?.dispose()
  categoryChart?.dispose()
})
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.dashboard-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  animation: fade-in-up 0.6s ease-out;
}

// Welcome Banner
.welcome-banner {
  @include glass-card;
  padding: 3rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(255,255,255,0.8) 0%, rgba(255,255,255,0.4) 100%);
  
  .welcome-content {
    display: flex;
    align-items: center;
    gap: 2.5rem;
    z-index: 2;
  }
  
  .user-avatar {
    border: 4px solid white;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
  }
  
  .welcome-text {
    h2 {
      font-size: 2.2rem;
      font-weight: 800;
      margin-bottom: 0.5rem;
      color: map.get($theme, text-main);
      
      .gradient-text { @include aurora-text; }
    }
    
    .time-display {
      font-size: 1.1rem;
      color: map.get($theme, text-light);
      margin-bottom: 1.2rem;
    }
  }
  
  .banner-illustration {
    position: absolute;
    right: -20px;
    bottom: -20px;
    opacity: 0.05;
    .bg-icon { font-size: 200px; }
  }
}

// Stats Grid
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
}

.stats-card {
  padding: 2rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  @include hover-lift;
  
  .stats-icon {
    width: 56px;
    height: 56px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    color: white;
  }
  
  .stats-info {
    .label { font-size: 0.9rem; color: map.get($theme, text-light); font-weight: 500; }
    .number { font-size: 2rem; font-weight: 800; color: map.get($theme, text-main); margin: 0; }
  }
  
  &.accent-blue .stats-icon { background: linear-gradient(135deg, #6366f1, #818cf8); }
  &.accent-pink .stats-icon { background: linear-gradient(135deg, #ec4899, #f472b6); }
  &.accent-indigo .stats-icon { background: linear-gradient(135deg, #4f46e5, #6366f1); }
  &.accent-violet .stats-icon { background: linear-gradient(135deg, #8b5cf6, #a78bfa); }
}

// Charts Grid
.charts-grid {
  display: grid;
  grid-template-columns: 1.6fr 1fr;
  gap: 1.5rem;
}

.chart-container {
  padding: 2rem;
  min-height: 450px;
  display: flex;
  flex-direction: column;
  
  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    
    .chart-title { font-size: 1.25rem; font-weight: 700; color: map.get($theme, text-main); margin: 0; }
  }
  
  .chart-box { flex: 1; width: 100%; }
}

// Responsive
@media (max-width: 1200px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
  .charts-grid { grid-template-columns: 1fr; }
}

@media (max-width: 768px) {
  .welcome-banner { padding: 2rem; .welcome-content { flex-direction: column; text-align: center; gap: 1.5rem; } }
  .stats-grid { grid-template-columns: 1fr; }
}
</style> 