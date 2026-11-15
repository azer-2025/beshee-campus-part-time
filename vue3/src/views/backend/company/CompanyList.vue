<template>
  <div class="company-list-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>企业管理</h2>
        <div class="header-actions">
          <el-button type="primary" class="aurora-btn" @click="refreshCompanies">
            <el-icon><Refresh /></el-icon> 刷新数据
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索表单 -->
    <div class="search-panel glass-card" v-if="userStore.isAdmin">
      <el-form :model="searchForm" inline class="aurora-search-bar">
        <el-form-item label="企业名称">
          <el-input v-model="searchForm.companyName" placeholder="输入名称关键词" clearable />
        </el-form-item>
        <el-form-item label="所属行业">
          <el-input v-model="searchForm.industry" placeholder="行业关键词" clearable />
        </el-form-item>
        <el-form-item label="认证状态">
          <el-select v-model="searchForm.verified" placeholder="全部状态" clearable class="status-select">
            <el-option label="已认证" :value="true" />
            <el-option label="未认证" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="handleSearch">
            <el-icon><Search /></el-icon> 查询
          </el-button>
          <el-button class="aurora-btn" @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 企业列表表格 -->
    <div class="table-wrapper">
      <!-- 管理员视图 -->
      <template v-if="userStore.isAdmin">
        <el-table
          v-loading="loading"
          :data="tableData"
          class="aurora-table"
          row-key="id"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="companyName" label="企业名称" min-width="180" show-overflow-tooltip />
          <el-table-column prop="industry" label="所属行业" width="140" show-overflow-tooltip />
          <el-table-column prop="companySize" label="规模" width="120" />
          <el-table-column prop="companyAddress" label="总部地址" min-width="180" show-overflow-tooltip />
          <el-table-column label="认证" width="100" align="center">
            <template #default="scope">
              <el-tag :type="scope.row.verified ? 'success' : 'danger'" class="aurora-tag">
                {{ scope.row.verified ? '已认证' : '未认证' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="220" fixed="right">
            <template #default="scope">
              <div class="action-btns">
                <el-button link type="primary" class="aurora-btn" @click="viewCompanyDetail(scope.row)">查看</el-button>
                <el-button
                  link
                  :type="scope.row.verified ? 'danger' : 'success'"
                  class="aurora-btn"
                  @click="toggleVerifyStatus(scope.row)"
                >
                  {{ scope.row.verified ? '撤销' : '认证' }}
                </el-button>
                <el-popconfirm title="确定删除该企业吗？" @confirm="deleteCompany(scope.row)">
                  <template #reference>
                    <el-button link type="danger" class="aurora-btn">删除</el-button>
                  </template>
                </el-popconfirm>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next"
            :total="total"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            class="aurora-pagination"
          />
        </div>
      </template>

      <!-- 企业用户视图 -->
      <template v-else-if="userStore.isCompany">
        <div v-if="companyInfo" class="company-profile-card glass-card">
          <div class="profile-header">
            <div class="logo-box">
              <img v-if="companyInfo.companyLogo" :src="getImageUrl(companyInfo.companyLogo)" alt="Logo" />
              <el-icon v-else><OfficeBuilding /></el-icon>
            </div>
            <div class="title-box">
              <h3>{{ companyInfo.companyName }}</h3>
              <el-tag :type="companyInfo.verified ? 'success' : 'warning'" class="aurora-tag">
                {{ companyInfo.verified ? '官方认证' : '待认证' }}
              </el-tag>
            </div>
            <el-button type="primary" class="aurora-btn edit-btn" @click="editCompanyInfo">
              <el-icon><Edit /></el-icon> 编辑资料
            </el-button>
          </div>
          
          <div class="profile-details">
            <div class="detail-row">
              <div class="item">
                <label>所属行业</label>
                <span>{{ companyInfo.industry || '未填写' }}</span>
              </div>
              <div class="item">
                <label>人员规模</label>
                <span>{{ companyInfo.companySize || '未填写' }}</span>
              </div>
              <div class="item">
                <label>总部地址</label>
                <span>{{ companyInfo.companyAddress || '未填写' }}</span>
              </div>
            </div>
            
            <div class="intro-section">
              <label>企业简介</label>
              <div class="content">{{ companyInfo.companyIntro || '暂无详细介绍' }}</div>
            </div>
          </div>
        </div>
        
        <el-empty v-else description="您的企业资料尚未完善">
          <el-button type="primary" class="aurora-btn" @click="router.push('/company/profile')">立即完善</el-button>
        </el-empty>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import DateUtils from '@/utils/dateUtils'
import { useUserStore } from '@/store/user'
import { OfficeBuilding, Refresh, Search, Edit } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const companyInfo = ref(null)

const searchForm = reactive({ companyName: '', industry: '', verified: null })

const fetchCompanies = async () => {
  if (!userStore.isAdmin) { await fetchCompanyInfo(); return }
  loading.value = true
  request.get('/company/page', {
    ...searchForm, currentPage: currentPage.value, size: pageSize.value
  }, {
    onSuccess: (res) => { tableData.value = res.records || []; total.value = res.total || 0 },
    onFinally: () => loading.value = false
  })
}

const fetchCompanyInfo = async () => {
  loading.value = true
  request.get(`/company/user/${userStore.userInfo.id}`, {
    showDefaultMsg: false,
    onSuccess: (data) => companyInfo.value = data,
    onFinally: () => loading.value = false
  })
}

const handleSearch = () => { currentPage.value = 1; fetchCompanies() }
const resetSearch = () => { searchForm.companyName = ''; searchForm.industry = ''; searchForm.verified = null; handleSearch() }
const refreshCompanies = () => fetchCompanies()
const handleSizeChange = (s) => { pageSize.value = s; fetchCompanies() }
const handleCurrentChange = (p) => { currentPage.value = p; fetchCompanies() }
const viewCompanyDetail = (row) => router.push(`/back/company/detail/${row.id}`)
const editCompanyInfo = () => router.push('/company/profile')

const toggleVerifyStatus = async (row) => {
  const verified = !row.verified
  request.put(`/company/${row.id}/verify`, null, { params: { verified }, onSuccess: () => row.verified = verified })
}

const deleteCompany = (row) => {
  request.delete(`/company/${row.id}`, { onSuccess: fetchCompanies })
}

const getImageUrl = (path) => path ? (import.meta.env.VITE_APP_BASE_API || '/api') + path : ''

onMounted(fetchCompanies)
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.company-list-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
  .status-select { width: 140px !important; }
}

.company-profile-card {
  padding: 3rem; background: white; border-radius: 24px;
  .profile-header {
    display: flex; align-items: center; gap: 2rem; margin-bottom: 3rem; position: relative;
    .logo-box {
      width: 120px; height: 120px; background: #f9fafb; border-radius: 20px; display: flex; align-items: center; justify-content: center;
      border: 1px solid rgba(0,0,0,0.05); overflow: hidden; img { width: 100%; height: 100%; object-fit: contain; }
      .el-icon { font-size: 3rem; color: #d1d5db; }
    }
    .title-box { flex: 1; h3 { font-size: 2rem; font-weight: 800; @include aurora-text; margin: 0 0 0.8rem; } }
    .edit-btn { position: absolute; top: 0; right: 0; }
  }
  .profile-details {
    .detail-row {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem; margin-bottom: 3rem;
      .item { display: flex; flex-direction: column; gap: 0.5rem; label { font-size: 0.9rem; font-weight: 700; color: #6b7280; } span { font-size: 1.1rem; font-weight: 600; color: #1f2937; } }
    }
    .intro-section { label { font-size: 0.9rem; font-weight: 700; color: #6b7280; display: block; margin-bottom: 1rem; } .content { padding: 2rem; background: #f9fafb; border-radius: 16px; line-height: 1.8; color: #4b5563; white-space: pre-wrap; } }
  }
}
</style> 
