<template>
  <div class="application-list-container">
    <div class="page-header">
      <h2>我的投递记录</h2>
      <div class="statistics">
        <el-row :gutter="20">
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">总投递</div>
              <div class="statistic-value">{{ statistics.totalCount || 0 }}</div>
            </el-card>
          </el-col>
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">待查看</div>
              <div class="statistic-value">{{ statistics.pendingCount || 0 }}</div>
            </el-card>
          </el-col>
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">已查看</div>
              <div class="statistic-value">{{ statistics.viewedCount || 0 }}</div>
            </el-card>
          </el-col>
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">通过筛选</div>
              <div class="statistic-value">{{ statistics.passedCount || 0 }}</div>
            </el-card>
          </el-col>
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">面试邀请</div>
              <div class="statistic-value">{{ statistics.interviewCount || 0 }}</div>
            </el-card>
          </el-col>
          <el-col :span="4">
            <el-card shadow="hover" class="statistic-card">
              <div class="statistic-title">已录用</div>
              <div class="statistic-value">{{ statistics.offeredCount || 0 }}</div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </div>
    
    <div class="filter-container">
      <el-form :inline="true" :model="searchForm" class="demo-form-inline">
        <el-form-item label="状态">
          <el-radio-group v-model="searchForm.status" @change="handleStatusChange">
            <el-radio-button :label="null">全部</el-radio-button>
            <el-radio-button :label="0">待查看</el-radio-button>
            <el-radio-button :label="1">已查看</el-radio-button>
            <el-radio-button :label="2">通过筛选</el-radio-button>
            <el-radio-button :label="3">面试邀请</el-radio-button>
            <el-radio-button :label="4">不合适</el-radio-button>
            <el-radio-button :label="5">已录用</el-radio-button>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="投递时间">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            @change="handleDateChange"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <div class="application-list">
      <el-table
        v-loading="loading"
        :data="tableData"
        style="width: 100%"
        :empty-text="emptyText"
      >
        <el-table-column label="企业信息" width="220">
          <template #default="{ row }">
            <div class="company-info">
              <el-avatar :size="50" :src="row.companyLogo ? baseAPI + row.companyLogo : '/default-logo.png'" />
              <div class="company-name">{{ row.companyName }}</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column prop="positionName" label="职位名称" />
        
        <el-table-column prop="resumeName" label="简历名称" />
        
        <el-table-column label="投递状态" width="150">
          <template #default="{ row }">
            <el-tooltip
              :content="getStatusDescription(row.status)"
              placement="top"
              effect="light"
              :show-after="500"
            >
              <el-tag :type="getStatusType(row.status)" effect="light" class="status-tag">
                <el-icon v-if="row.status === 0"><Clock /></el-icon>
                <el-icon v-else-if="row.status === 1"><View /></el-icon>
                <el-icon v-else-if="row.status === 2"><Check /></el-icon>
                <el-icon v-else-if="row.status === 3"><Bell /></el-icon>
                <el-icon v-else-if="row.status === 4"><Close /></el-icon>
                <el-icon v-else-if="row.status === 5"><CircleCheck /></el-icon>
                {{ getStatusName(row.status) }}
              </el-tag>
            </el-tooltip>
            <div class="status-progress">
              <div class="progress-bar">
                <div 
                  class="progress-step" 
                  v-for="step in 6" 
                  :key="step"
                  :class="{ 
                    'active': row.status >= step - 1, 
                    'rejected': row.status === 4 && step > 1,
                    'current': row.status === step - 1 
                  }"
                ></div>
              </div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column prop="createTime" label="投递时间" width="180" />
        
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="viewPosition(row.positionId)">查看职位</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination
          background
          layout="prev, pager, next, total"
          :total="total"
          :page-size="pageSize"
          :current-page="currentPage"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Clock, View, Check, Bell, Close, CircleCheck } from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const baseAPI = import.meta.env.VITE_APP_BASE_API || '/api'

// 表格数据
const tableData = ref([])
const loading = ref(false)
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const emptyText = ref('暂无投递记录')

// 统计数据
const statistics = ref({
  totalCount: 0,
  pendingCount: 0,
  viewedCount: 0,
  passedCount: 0,
  interviewCount: 0,
  rejectedCount: 0,
  offeredCount: 0
})

// 搜索条件
const searchForm = ref({
  status: null,
  dateRange: null,
  startDate: null,
  endDate: null
})

// 获取投递记录
const fetchApplications = async () => {
  loading.value = true
  try {
    await request.get('/application/student', {
      status: searchForm.value.status,
      startDate: searchForm.value.startDate,
      endDate: searchForm.value.endDate,
      currentPage: currentPage.value,
      size: pageSize.value
    }, {
      onSuccess: (res) => {
        tableData.value = res.records || []
        total.value = res.total || 0
        
        if (tableData.value.length === 0) {
          if (searchForm.value.status !== null || searchForm.value.startDate || searchForm.value.endDate) {
            emptyText.value = '没有符合条件的投递记录'
          } else {
            emptyText.value = '暂无投递记录，快去投递简历吧！'
          }
        }
      }
    })
  } finally {
    loading.value = false
  }
}

// 获取统计信息
const fetchStatistics = async () => {
  try {
    await request.get('/application/statistics', {}, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        statistics.value = res || {}
      }
    })
  } catch (error) {
    console.error('获取统计信息失败', error)
  }
}

// 状态变更
const handleStatusChange = () => {
  currentPage.value = 1
  fetchApplications()
}

// 日期变更
const handleDateChange = () => {
  if (searchForm.value.dateRange) {
    searchForm.value.startDate = searchForm.value.dateRange[0]
    searchForm.value.endDate = searchForm.value.dateRange[1]
  } else {
    searchForm.value.startDate = null
    searchForm.value.endDate = null
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchApplications()
}

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    status: null,
    dateRange: null,
    startDate: null,
    endDate: null
  }
  currentPage.value = 1
  fetchApplications()
}

// 页码变更
const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchApplications()
}

// 获取状态名称
const getStatusName = (status) => {
  const statusMap = {
    0: '待查看',
    1: '已查看',
    2: '通过筛选',
    3: '面试邀请',
    4: '不合适',
    5: '已录用'
  }
  return statusMap[status] || '未知状态'
}

// 获取状态标签类型
const getStatusType = (status) => {
  const typeMap = {
    0: 'info',
    1: '',
    2: 'success',
    3: 'warning',
    4: 'danger',
    5: 'success'
  }
  return typeMap[status] || ''
}

// 获取状态详细描述
const getStatusDescription = (status) => {
  const descriptionMap = {
    0: '您的简历已投递，等待企业查看',
    1: '企业已查看您的简历',
    2: '恭喜！您的简历已通过初步筛选',
    3: '企业已向您发送面试邀请，请注意查收',
    4: '抱歉，企业认为您与该职位不太匹配',
    5: '恭喜！企业已决定录用您'
  }
  return descriptionMap[status] || '未知状态'
}

// 查看职位
const viewPosition = (positionId) => {
  router.push(`/position/detail/${positionId}`)
}

onMounted(() => {
  fetchApplications()
  fetchStatistics()
})
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.application-list-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem 4rem;
  font-family: var(--font-family-base);
}

.page-header {
  @include page-header-glass;
  margin-bottom: 2rem;
  h2 { margin-bottom: 2rem; }
}

.statistics {
  margin-top: 2rem;
  .statistic-card {
    background: rgba(255, 255, 255, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.8);
    border-radius: 16px;
    padding: 1.2rem;
    @include hover-lift;
    
    .statistic-title { font-size: 0.85rem; color: map.get($theme, text-light); font-weight: 600; margin-bottom: 0.5rem; }
    .statistic-value { font-size: 1.8rem; font-weight: 800; @include aurora-text; }
  }
}

.filter-container {
  @include glass-card;
  background: map.get($theme, card-gradient-1);
  padding: 1.5rem 2rem;
  margin-bottom: 2rem;
  
  :deep(.el-form-item) {
    margin-bottom: 0;
    margin-right: 2rem;
    .el-form-item__label { font-weight: 700; color: map.get($theme, text-main); }
  }
  
  :deep(.el-radio-button__inner) {
    background: white;
    border: 1px solid rgba(0,0,0,0.05);
    margin-right: 8px;
    border-radius: 8px !important;
    font-weight: 600;
    color: map.get($theme, text-light);
    box-shadow: none !important;
  }
  
  :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
    background: map.get($theme, primary);
    border-color: map.get($theme, primary);
    color: white;
  }

  :deep(.el-range-editor.el-input__wrapper) {
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.04) !important;
  }
}

.application-list {
  @include glass-card;
  background: map.get($theme, card-gradient-1);
  padding: 1rem;
}

:deep(.el-table) {
  background: transparent !important;
  --el-table-bg-color: transparent;
  --el-table-tr-bg-color: transparent;
  
  th.el-table__cell {
    color: map.get($theme, text-main);
    font-weight: 700;
    padding: 1.2rem 0;
    background: rgba(99, 102, 241, 0.05);
  }
  
  td.el-table__cell {
    color: map.get($theme, text-light);
    font-weight: 500;
    padding: 1.2rem 0;
  }
}

.company-info {
  display: flex;
  align-items: center;
  gap: 12px;
  .company-name { font-weight: 700; color: map.get($theme, text-main); font-size: 1rem; }
  .el-avatar { border: 2px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
}

.status-tag {
  border-radius: 8px;
  font-weight: 700;
  padding: 6px 12px;
  border: none;
  font-size: 0.85rem;
}

.status-progress {
  margin-top: 10px;
  .progress-bar {
    height: 6px;
    background: rgba(0,0,0,0.03);
    border-radius: 10px;
    padding: 0 2px;
    .progress-step {
      border-radius: 10px;
      &.active { background: #10b981; }
      &.current { background: map.get($theme, primary); box-shadow: 0 0 8px rgba(99, 102, 241, 0.4); }
      &.rejected { background: #f43f5e; }
    }
  }
}

.pagination-container {
  margin-top: 2.5rem;
  display: flex;
  justify-content: center;
  :deep(.el-pagination.is-background .el-pager li:not(.is-disabled).is-active) {
    background-color: map.get($theme, primary);
  }
}
</style> 