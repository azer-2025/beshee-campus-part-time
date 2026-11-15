<template>
  <div class="position-list-container backend-container">
    <!-- 头部 -->
    <div class="aurora-card">
      <div class="card-header">
        <h2>职位管理</h2>
        <div class="header-actions">
          <el-button 
            type="primary" 
            class="aurora-btn" 
            @click="handleAdd" 
            v-if="isCompanyUser"
          >
            <el-icon><Plus /></el-icon> 发布新职位
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索表单 -->
    <div class="search-panel glass-card">
      <el-form :model="searchForm" ref="searchFormRef" inline class="aurora-search-bar">
        <el-form-item label="职位名称">
          <el-input v-model="searchForm.positionName" placeholder="职位名称" clearable />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="searchForm.positionType" placeholder="全部类型" clearable class="status-select">
            <el-option v-for="item in positionTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="工作地点">
          <el-input v-model="searchForm.workAddress" placeholder="城市/地区" clearable />
        </el-form-item>
        <el-form-item label="状态" v-if="isAdmin">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable class="status-select">
            <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="handleSearch">搜索</el-button>
          <el-button class="aurora-btn" @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 职位列表 -->
    <div class="table-wrapper">
      <div v-if="tableData.length === 0 && !loading && isCompanyUser" class="empty-positions">
        <el-empty description="您还没有发布任何职位">
          <template #extra>
            <el-button type="primary" class="aurora-btn" @click="handleAdd">立即发布职位</el-button>
          </template>
        </el-empty>
      </div>
      
      <el-table v-else v-loading="loading" :data="tableData" class="aurora-table">
        <el-table-column label="企业信息" width="220">
          <template #default="{ row }">
            <div class="company-info-cell">
              <el-avatar :size="40" :src="getCompanyLogoUrl(row.companyLogo)" class="mini-logo" />
              <span class="company-name">{{ row.companyName || '未知企业' }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="positionName" label="职位名称" min-width="150" />
        <el-table-column prop="positionType" label="类型" width="100">
          <template #default="{ row }">
            <el-tag effect="plain" class="aurora-tag">{{ row.positionType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="薪资范围" width="140">
          <template #default="{ row }">
            <span class="salary-range">{{ row.salaryMin / 1000 }}k-{{ row.salaryMax / 1000 }}k</span>
          </template>
        </el-table-column>
        <el-table-column prop="workAddress" label="工作地点" min-width="120" show-overflow-tooltip />
        <el-table-column prop="educationRequirement" label="学历" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" class="aurora-tag">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <div class="action-btns">
              <el-button type="primary" link class="aurora-btn" @click="handleView(row)">详情</el-button>
              
              <template v-if="isAdmin && row.status === 2">
                <el-button type="success" link class="aurora-btn" @click="handleApprove(row)">通过</el-button>
                <el-button type="danger" link class="aurora-btn" @click="handleReject(row)">拒绝</el-button>
              </template>
              
              <template v-if="isAdmin && row.status === 1">
                <el-button type="warning" link class="aurora-btn" @click="handleOffline(row)">下线</el-button>
              </template>
              
              <el-button type="primary" link class="aurora-btn" @click="handleEdit(row)">编辑</el-button>
              <el-button type="danger" link class="aurora-btn" @click="handleDelete(row)">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          class="aurora-pagination"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import DateUtils from '@/utils/dateUtils'
import { getPositionPage, updatePositionStatus, deletePosition } from '@/api/position'
import { useUserStore } from '@/store/user'
import defaultLogo from '@/assets/logo.png'

const router = useRouter()
const userStore = useUserStore()

const isAdmin = computed(() => userStore.isAdmin)
const isCompanyUser = computed(() => userStore.isCompany)
const companyId = computed(() => userStore.companyInfo?.id)
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

const searchFormRef = ref(null)
const searchForm = reactive({
  positionName: '',
  positionType: '',
  workAddress: '',
  status: ''
})

const positionTypeOptions = [
  { value: '全职', label: '全职' },
  { value: '兼职', label: '兼职' },
  { value: '实习', label: '实习' },
  { value: '校招', label: '校招' }
]

const statusOptions = [
  { value: 0, label: '下线' },
  { value: 1, label: '上线' },
  { value: 2, label: '审核中' }
]

const baseAPI = import.meta.env.VITE_BASE_API || '/api'
const getCompanyLogoUrl = (logo) => {
  if (!logo) return defaultLogo
  return baseAPI + logo
}

const getStatusType = (status) => {
  switch (status) {
    case 0: return 'danger'
    case 1: return 'success'
    case 2: return 'warning'
    default: return 'info'
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 0: return '下线'
    case 1: return '上线'
    case 2: return '审核中'
    default: return '未知'
  }
}

const fetchPositions = async () => {
  loading.value = true
  try {
    const params = {
      ...searchForm,
      currentPage: currentPage.value,
      size: pageSize.value,
      companyId: isCompanyUser.value && !isAdmin.value ? companyId.value : undefined
    }
    await getPositionPage(params, {
      onSuccess: (data) => {
        tableData.value = data.records || []
        total.value = data.total || 0
      }
    })
  } finally {
    loading.value = false
  }
}

const handleSearch = () => { currentPage.value = 1; fetchPositions() }
const resetSearch = () => { searchFormRef.value.resetFields(); currentPage.value = 1; fetchPositions() }
const handleSizeChange = (val) => { pageSize.value = val; fetchPositions() }
const handleCurrentChange = (val) => { currentPage.value = val; fetchPositions() }
const handleView = (row) => { router.push(`/back/position/detail/${row.id}`) }
const handleAdd = () => { router.push('/back/position/form') }
const handleEdit = (row) => { router.push(`/back/position/form/${row.id}`) }

const handleDelete = (row) => {
  ElMessageBox.confirm('确定删除该职位吗？删除后不可恢复。', '删除确认', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
  }).then(() => {
    deletePosition(row.id, {
      successMsg: '职位删除成功',
      onSuccess: () => { fetchPositions() }
    })
  })
}

const handleApprove = (row) => {
  updatePositionStatus(row.id, { status: 1 }, {
    successMsg: '审核通过成功', onSuccess: () => { fetchPositions() }
  })
}

const handleReject = (row) => {
  updatePositionStatus(row.id, { status: 0 }, {
    successMsg: '审核拒绝成功', onSuccess: () => { fetchPositions() }
  })
}

const handleOffline = (row) => {
  updatePositionStatus(row.id, { status: 0 }, {
    successMsg: '职位下线成功', onSuccess: () => { fetchPositions() }
  })
}

onMounted(() => { fetchPositions() })
</script>

<style lang="scss" scoped>
.position-list-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
  .status-select { width: 140px !important; }
}

.company-info-cell {
  display: flex;
  align-items: center;
  gap: 12px;
  .company-name { font-weight: 700; color: #1f2937; font-size: 0.95rem; }
  .mini-logo { border: 2px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
}

.salary-range { font-weight: 800; color: #6366f1; }
.empty-positions { padding: 4rem 0; }
</style>