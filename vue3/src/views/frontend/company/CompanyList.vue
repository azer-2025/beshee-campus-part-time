<template>
  <div class="company-list-container">
    <div class="page-header">
      <h2>企业列表</h2>
      <p>发现优质企业，寻找理想职位</p>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-filter-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="企业名称">
          <el-input v-model="searchForm.companyName" placeholder="输入企业名称" clearable @keyup.enter="handleSearch" />
        </el-form-item>
        <el-form-item label="所属行业">
          <el-select v-model="searchForm.industry" placeholder="选择行业" clearable>
            <el-option v-for="item in industryOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 公司列表展示 -->
    <div v-loading="loading" class="company-list">
      <template v-if="companyList.length > 0">
        <el-row :gutter="20">
          <el-col v-for="company in companyList" :key="company.id" :xs="24" :sm="12" :md="8" :lg="6" :xl="6">
            <el-card class="company-card" shadow="hover" @click="viewCompanyDetail(company.id)">
              <div class="company-logo">
                <el-image 
                  :src="company.companyLogo ? baseAPI + company.companyLogo : '/default-company-logo.png'" 
                  fit="cover"
                  alt="公司logo"
                  :lazy="true">
                  <template #error>
                    <div class="image-placeholder">
                      <el-icon><OfficeBuilding /></el-icon>
                    </div>
                  </template>
                </el-image>
                <el-tag v-if="company.verified" type="success" size="small" class="verified-tag">已认证</el-tag>
              </div>
              <div class="company-info">
                <h3 class="company-name">{{ company.companyName }}</h3>
                <div class="company-meta">
                  <span><el-icon><Briefcase /></el-icon> {{ company.industry || '未知行业' }}</span>
                  <span><el-icon><User /></el-icon> {{ company.companySize || '未知规模' }}</span>
                </div>
                <div class="company-address" v-if="company.companyAddress">
                  <el-icon><Location /></el-icon> {{ company.companyAddress }}
                </div>
                <div class="company-intro">{{ truncateText(company.companyIntro, 50) }}</div>
                <div class="view-positions">
                  <el-button type="primary" link @click.stop="viewCompanyPositions(company.id)">
                    查看该企业职位 <el-icon><ArrowRight /></el-icon>
                  </el-button>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </template>
      <el-empty v-else description="暂无企业数据" />
    </div>

    <!-- 分页 -->
    <div class="pagination-container">
      <el-pagination
        :current-page="currentPage"
        :page-size="pageSize"
        :page-sizes="[8, 16, 24, 32]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        @update:current-page="currentPage = $event"
        @update:page-size="pageSize = $event"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { OfficeBuilding, Briefcase, User, Location, ArrowRight } from '@element-plus/icons-vue'

const router = useRouter()
const baseAPI = import.meta.env.VITE_BASE_API || '/api'

// 数据定义
const companyList = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(8)
const total = ref(0)
const searchForm = reactive({
  companyName: '',
  industry: ''
})

// 行业选项
const industryOptions = [
  { value: '互联网/IT', label: '互联网/IT' },
  { value: '金融', label: '金融' },
  { value: '教育', label: '教育' },
  { value: '医疗健康', label: '医疗健康' },
  { value: '制造业', label: '制造业' },
  { value: '房地产', label: '房地产' },
  { value: '零售/贸易', label: '零售/贸易' },
  { value: '文化/传媒', label: '文化/传媒' },
  { value: '服务业', label: '服务业' },
  { value: '其他', label: '其他' }
]

// 获取企业列表
const fetchCompanies = () => {
  loading.value = true
  request.get('/company/page', {
    companyName: searchForm.companyName,
    industry: searchForm.industry,
    verified: true, // 只显示已认证的企业
    currentPage: currentPage.value,
    size: pageSize.value
  }, {
    onSuccess: (res) => {
      companyList.value = res.records || []
      total.value = res.total || 0
            loading.value = false
    },
    onError: (error) => {
      console.error('获取企业列表失败:', error)
    }
  })
}

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1
  fetchCompanies()
}

// 重置搜索
const resetSearch = () => {
  searchForm.companyName = ''
  searchForm.industry = ''
  currentPage.value = 1
  fetchCompanies()
}

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size
  fetchCompanies()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchCompanies()
}

// 查看企业详情
const viewCompanyDetail = (id) => {
  try {
    router.push(`/company-detail/${id}`)
  } catch (error) {
    console.error('导航失败:', error)
    // 可以添加一个提示
    ElMessage.error('页面导航失败，请稍后再试')
  }
}


// 查看企业职位
const viewCompanyPositions = (id) => {
  router.push(`/positions?companyId=${id}`)
}

// 文本截断
const truncateText = (text, length) => {
  if (!text) return '暂无简介'
  return text.length > length ? text.substring(0, length) + '...' : text
}

// 页面加载时获取数据
onMounted(() => {
  fetchCompanies()
})
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.company-list-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem 2rem;
  font-family: var(--font-family-base);
}

.page-header {
  @include page-header-glass;
}

.search-filter-container {
  @include glass-card;
  padding: 2rem;
  margin-bottom: 2rem;
  
  :deep(.el-form) {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    align-items: flex-end;
    
    .el-form-item {
      margin-bottom: 0;
      margin-right: 0;
    }

    .el-input__wrapper {
      background: white;
      border-radius: 10px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.04) !important;
      border: 1px solid rgba(0,0,0,0.05);
      
      &.is-focus {
        border-color: map.get($theme, primary);
      }
    }

    .el-select {
      .el-input__wrapper {
        background: white;
      }
    }

    .el-button {
      height: 40px;
      border-radius: 10px;
      padding: 0 1.5rem;
      font-weight: 600;
      
      &.el-button--primary {
        background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
        border: none;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
      }
    }
  }
}

.company-list {
  min-height: 400px;
}

.company-card {
  @include glass-card;
  margin-bottom: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  background: map.get($theme, card-gradient-1);
  overflow: hidden;
  height: 100%;
  
  &:hover {
    transform: translateY(-5px);
    background: map.get($theme, card-gradient-hover);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
  }
}

.company-logo {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  background: white;
  padding: 1.5rem;
  border-bottom: 1px solid rgba(0,0,0,0.05);

  .el-image {
    height: 80px;
    width: auto;
    object-fit: contain;
  }

  .verified-tag {
    position: absolute;
    top: 0.8rem;
    right: 0.8rem;
    background: rgba(16, 185, 129, 0.1);
    border: none;
    color: #059669;
    font-weight: 600;
  }
}

.image-placeholder {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 80px;
  background: #f9fafb;
  color: #d1d5db;
  font-size: 2rem;
}

.company-info {
  padding: 1.2rem;
}

.company-name {
  font-size: 1.2rem;
  font-weight: 700;
  color: map.get($theme, text-main);
  margin-bottom: 0.8rem;
}

.company-meta {
  display: flex;
  justify-content: space-between;
  color: map.get($theme, text-light);
  font-size: 0.85rem;
  margin-bottom: 0.8rem;

  span {
    display: flex;
    align-items: center;
    gap: 0.4rem;
  }
}

.company-address {
  display: flex;
  align-items: center;
  color: map.get($theme, text-light);
  font-size: 0.85rem;
  margin-bottom: 0.8rem;
  gap: 0.4rem;
}

.company-intro {
  color: map.get($theme, text-light);
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 1.2rem;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.view-positions {
  border-top: 1px solid rgba(0,0,0,0.05);
  padding-top: 1rem;
  text-align: right;

  .el-button {
    font-weight: 600;
    color: map.get($theme, primary);
    &:hover { color: map.get($theme, accent); }
  }
}

.pagination-container {
  margin-top: 3rem;
  display: flex;
  justify-content: center;
  
  :deep(.el-pagination) {
    .el-pager li {
      background: rgba(255, 255, 255, 0.5);
      backdrop-filter: blur(4px);
      border-radius: 8px;
      margin: 0 4px;
      border: 1px solid rgba(0,0,0,0.05);
      
      &.is-active {
        background: map.get($theme, primary);
        color: white;
        border: none;
      }
    }
  }
}
</style> 