<template>
  <div class="application-management-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>投递记录管理</h2>
        <div class="statistics-hub">
          <div class="stat-pill">
            <span class="label">待处理</span>
            <span class="val">{{ statistics.pendingCount || 0 }}</span>
          </div>
          <div class="stat-pill">
            <span class="label">面试中</span>
            <span class="val">{{ statistics.interviewCount || 0 }}</span>
          </div>
          <div class="stat-pill offered">
            <span class="label">已录用</span>
            <span class="val">{{ statistics.offeredCount || 0 }}</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 过滤器 -->
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" class="aurora-search-bar">
        <el-form-item label="目标职位">
          <el-select v-model="searchForm.positionId" placeholder="全部职位" clearable @change="handleSearch">
            <el-option v-for="item in positionOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="当前状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable @change="handleSearch">
            <el-option label="待查看" :value="0" />
            <el-option label="已查看" :value="1" />
            <el-option label="通过筛选" :value="2" />
            <el-option label="面试邀请" :value="3" />
            <el-option label="不合适" :value="4" />
            <el-option label="已录用" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="searchForm.keyword" placeholder="姓名 / 学号" clearable @keyup.enter="handleSearch" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="handleSearch">查询</el-button>
          <el-button class="aurora-btn" @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <div class="table-wrapper">
      <div class="table-actions">
        <el-button-group>
          <el-button type="primary" class="aurora-btn" :disabled="!hasSelected" @click="batchMarkAsViewed">
            <el-icon><View /></el-icon> 标记已读
          </el-button>
          <el-button type="success" class="aurora-btn" :disabled="!hasSelected" @click="batchMarkAsPassed">
            <el-icon><Check /></el-icon> 批量通过
          </el-button>
        </el-button-group>
      </div>
      
      <el-table
        v-loading="loading"
        :data="tableData"
        class="aurora-table"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        
        <el-table-column label="候选人" width="200">
          <template #default="{ row }">
            <div class="student-profile-cell" @click="viewStudentDetail(row)">
              <div class="name">{{ row.studentName }}</div>
              <div class="no">{{ row.studentNo }}</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column prop="positionName" label="投递职位" min-width="150" />
        <el-table-column prop="resumeName" label="所选简历" min-width="150" />
        
        <el-table-column label="当前状态" width="140">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="plain" class="aurora-tag">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        
        <el-table-column prop="createTime" label="投递时间" width="180" />
        
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <div class="action-btns">
              <el-button type="primary" link class="aurora-btn" @click="previewResume(row.resumeId)">
                <el-icon><Document /></el-icon> 简历
              </el-button>
              <el-dropdown @command="(c) => handleStatusChange(row.id, c)">
                <el-button type="primary" link class="aurora-btn">
                  状态 <el-icon><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item :command="1">标记已查看</el-dropdown-item>
                    <el-dropdown-item :command="2">通过筛选</el-dropdown-item>
                    <el-dropdown-item :command="3">面试邀请</el-dropdown-item>
                    <el-dropdown-item :command="4">标记不合适</el-dropdown-item>
                    <el-dropdown-item :command="5">录用确认</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          layout="total, prev, pager, next"
          :total="total"
          @current-change="handleCurrentChange"
          class="aurora-pagination"
        />
      </div>
    </div>

    <!-- 简历详情预览弹窗 (Aurora Version) -->
    <el-dialog v-model="resumeDialogVisible" title="简历全屏预览" width="1000px" class="aurora-dialog">
      <div v-loading="resumeLoading" class="resume-preview-hub">
        <div v-if="resumeData" class="resume-body">
          <div class="resume-main-header">
            <div class="title-left">
              <h1>{{ resumeData.studentName }}的个人简历</h1>
              <p class="resume-subtitle">{{ resumeData.resumeName }}</p>
            </div>
            <el-tag effect="dark" round class="aurora-tag status-tag">投递版本</el-tag>
          </div>
          
          <div class="resume-grid" v-if="resumeData.resumeContent">
            <!-- 基本信息 -->
            <div class="glass-card resume-block">
              <div class="block-title"><el-icon><UserFilled /></el-icon> 核心资料</div>
              <el-descriptions :column="2" border size="small" class="custom-descriptions" v-if="resumeData.resumeContent.basicInfo">
                <el-descriptions-item label="姓名">{{ resumeData.resumeContent.basicInfo.name }}</el-descriptions-item>
                <el-descriptions-item label="邮箱">{{ resumeData.resumeContent.basicInfo.email }}</el-descriptions-item>
                <el-descriptions-item label="电话">{{ resumeData.resumeContent.basicInfo.phone }}</el-descriptions-item>
                <el-descriptions-item label="出生">{{ resumeData.resumeContent.basicInfo.birthDate }}</el-descriptions-item>
                <el-descriptions-item label="住址" :span="2">{{ resumeData.resumeContent.basicInfo.address }}</el-descriptions-item>
              </el-descriptions>
            </div>

            <!-- 求职意向 -->
            <div class="glass-card resume-block" v-if="resumeData.resumeContent.jobIntention">
              <div class="block-title"><el-icon><Aim /></el-icon> 兼职意向</div>
              <el-descriptions :column="2" border size="small" class="custom-descriptions">
                <el-descriptions-item label="目标岗位">{{ resumeData.resumeContent.jobIntention.position }}</el-descriptions-item>
                <el-descriptions-item label="期望薪资">{{ resumeData.resumeContent.jobIntention.salaryExpectation }}</el-descriptions-item>
                <el-descriptions-item label="所属行业">{{ resumeData.resumeContent.jobIntention.industry }}</el-descriptions-item>
                <el-descriptions-item label="工作地点">{{ resumeData.resumeContent.jobIntention.location }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </div>
          
          <div class="resume-full-content" v-if="resumeData.resumeContent">
            <div class="glass-card resume-block" v-if="resumeData.resumeContent.education">
              <div class="block-title"><el-icon><School /></el-icon> 教育背景</div>
              <div v-for="(edu, i) in resumeData.resumeContent.education" :key="i" class="list-item">
                <div class="item-header">
                  <span class="item-main">{{ edu.school }}</span>
                  <span class="item-date">{{ edu.startDate }} - {{ edu.endDate }}</span>
                </div>
                <div class="item-sub">{{ edu.major }} · {{ edu.degree }}</div>
                <p v-if="edu.description" class="item-desc">{{ edu.description }}</p>
              </div>
            </div>

            <div class="glass-card resume-block" v-if="resumeData.resumeContent.workExperience">
              <div class="block-title"><el-icon><Briefcase /></el-icon> 实践/工作经历</div>
              <div v-for="(work, i) in resumeData.resumeContent.workExperience" :key="i" class="list-item">
                <div class="item-header">
                  <span class="item-main">{{ work.company }}</span>
                  <span class="item-date">{{ work.startDate }} - {{ work.endDate }}</span>
                </div>
                <div class="item-sub">{{ work.position }}</div>
                <p class="item-desc">{{ work.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="resumeDialogVisible = false" round>关闭预览</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 学生详情 -->
    <el-dialog v-model="studentDialogVisible" title="学生档案详情" width="550px" class="aurora-dialog">
      <div v-loading="studentLoading" class="student-profile-hub">
        <div v-if="currentStudent" class="profile-content">
          <div class="profile-item">
            <label>真实姓名</label>
            <div class="val">{{ currentStudent.user?.name || '未填写' }}</div>
          </div>
          <div class="profile-row">
            <div class="profile-item">
              <label>学号</label>
              <div class="val">{{ currentStudent.studentNo }}</div>
            </div>
            <div class="profile-item">
              <label>最高学历</label>
              <div class="val"><el-tag class="aurora-tag">{{ currentStudent.education }}</el-tag></div>
            </div>
          </div>
          <div class="profile-item">
            <label>就读学院</label>
            <div class="val">{{ currentStudent.college }}</div>
          </div>
          <div class="profile-item">
            <label>所属专业</label>
            <div class="val">{{ currentStudent.major }}</div>
          </div>
        </div>
      </div>
    </el-dialog>

    <send-interview-invitation
      v-if="currentApplicationId"
      :application-id="currentApplicationId"
      ref="interviewInvitationRef"
      @success="handleInterviewInvitationSuccess"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ArrowDown, View, Check, Document, UserFilled, Search, Aim, School, Briefcase } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import SendInterviewInvitation from './components/SendInterviewInvitation.vue'

const tableData = ref([])
const loading = ref(false)
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const selectedRows = ref([])
const hasSelected = computed(() => selectedRows.value.length > 0)

const statistics = ref({ totalCount: 0, pendingCount: 0, viewedCount: 0, passedCount: 0, interviewCount: 0, rejectedCount: 0, offeredCount: 0 })
const searchForm = ref({ positionId: null, status: null, keyword: null })
const positionOptions = ref([])

const resumeDialogVisible = ref(false)
const resumeLoading = ref(false)
const resumeData = ref(null)
const studentDialogVisible = ref(false)
const studentLoading = ref(false)
const currentStudent = ref(null)
const currentApplicationId = ref(null)
const interviewInvitationRef = ref(null)

const fetchPositions = async () => {
  request.get('/position/list', {}, { onSuccess: (res) => {
    positionOptions.value = (res || []).map(item => ({ value: item.id, label: item.positionName }))
  }})
}

const fetchApplications = async () => {
  loading.value = true
  request.get('/application/page', {
    ...searchForm.value, currentPage: currentPage.value, size: pageSize.value
  }, {
    onSuccess: (res) => { tableData.value = res.records || []; total.value = res.total || 0 },
    onFinally: () => loading.value = false
  })
}

const fetchStatistics = async () => {
  request.get('/application/statistics', {}, { onSuccess: (res) => statistics.value = res || {} })
}

const handleSearch = () => { currentPage.value = 1; fetchApplications() }
const resetSearch = () => { searchForm.value = { positionId: null, status: null, keyword: null }; handleSearch() }
const handleCurrentChange = (page) => { currentPage.value = page; fetchApplications() }
const handleSelectionChange = (rows) => { selectedRows.value = rows }

const getStatusName = (s) => ({ 0: '待查看', 1: '已查看', 2: '通过筛选', 3: '面试邀请', 4: '不合适', 5: '已录用' }[s] || '未知')
const getStatusType = (s) => ({ 0: 'info', 1: '', 2: 'success', 3: 'warning', 4: 'danger', 5: 'success' }[s] || '')

const previewResume = (id) => {
  resumeLoading.value = true; resumeDialogVisible.value = true
  request.get(`/resume/${id}`, {}, {
    onSuccess: (res) => {
      if (res && res.resumeContent) {
        try { 
          if(typeof res.resumeContent === 'string') {
            res.resumeContent = JSON.parse(res.resumeContent) 
          }
        } catch (e) { console.error(e) }
      }
      resumeData.value = res
    },
    onFinally: () => resumeLoading.value = false
  })
}

const viewStudentDetail = (row) => {
  studentLoading.value = true; studentDialogVisible.value = true
  request.get(`/student/${row.studentId}`, {}, {
    onSuccess: (res) => currentStudent.value = res,
    onFinally: () => studentLoading.value = false
  })
}

const handleStatusChange = (id, status) => {
  if (status === 3) { currentApplicationId.value = id; setTimeout(() => interviewInvitationRef.value.dialogVisible = true, 0); return }
  ElMessageBox.confirm(`确认更改状态为 ${getStatusName(status)}？`, '提示').then(() => {
    request.put(`/application/status/${id}?status=${status}`, null, { onSuccess: () => { fetchApplications(); fetchStatistics() }})
  })
}

const batchUpdateStatus = (status) => {
  const ids = selectedRows.value.map(r => r.id)
  ElMessageBox.confirm(`确认批量更新 ${ids.length} 条记录？`, '批量操作').then(async () => {
    for (const id of ids) {
      await request.put(`/application/status/${id}?status=${status}`, null, { showDefaultMsg: false })
    }
    ElMessage.success('操作成功'); fetchApplications(); fetchStatistics()
  })
}

const batchMarkAsViewed = () => batchUpdateStatus(1)
const batchMarkAsPassed = () => batchUpdateStatus(2)
const handleInterviewInvitationSuccess = () => { fetchApplications(); fetchStatistics() }

onMounted(() => { fetchPositions(); fetchApplications(); fetchStatistics() })
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.application-management-container {
  .statistics-hub {
    display: flex; gap: 1rem;
    .stat-pill {
      background: rgba(255,255,255,0.5); padding: 6px 16px; border-radius: 100px; display: flex; align-items: center; gap: 8px;
      .label { font-size: 0.85rem; font-weight: 600; color: #6b7280; }
      .val { font-weight: 800; color: map.get($theme, primary); }
      &.offered { background: rgba(16, 185, 129, 0.1); .val { color: #059669; } }
    }
  }
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .table-actions { margin-bottom: 1.5rem; }
  .action-btns { display: flex; gap: 8px; }
}

.student-profile-cell {
  cursor: pointer;
  .name { font-weight: 700; color: map.get($theme, text-main); margin-bottom: 2px; }
  .no { font-size: 0.85rem; color: map.get($theme, primary); font-family: monospace; }
  &:hover .name { color: map.get($theme, primary); }
}

// Polished Resume Preview Hub
.resume-preview-hub {
  padding: 1rem 2rem 2rem;
  max-height: 70vh;
  overflow-y: auto;
  
  &::-webkit-scrollbar { width: 6px; }
  &::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.05); border-radius: 3px; }

  .resume-main-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 3rem;
    padding-bottom: 1.5rem;
    border-bottom: 1px solid rgba(0,0,0,0.05);
    
    .title-left {
      h1 { font-size: 2.2rem; font-weight: 800; @include aurora-text; margin: 0 0 0.5rem; }
      .resume-subtitle { font-size: 1.1rem; color: #6b7280; font-weight: 500; margin: 0; }
    }
    .status-tag { margin-top: 0.5rem; }
  }
}

.resume-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  margin-bottom: 2rem;
}

.resume-block {
  padding: 2rem;
  background: white;
  border-radius: 20px;
  @include glass-card;
  animation: none;
  
  .block-title {
    font-size: 1.15rem;
    font-weight: 800;
    color: map.get($theme, primary);
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 1.5rem;
    padding-bottom: 0.8rem;
    border-bottom: 2px solid rgba(99, 102, 241, 0.1);
  }
}

.custom-descriptions {
  :deep(.el-descriptions__label) {
    background: #f9fafb !important;
    font-weight: 700 !important;
    width: 90px;
  }
}

.list-item {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px dashed rgba(0,0,0,0.05);
  &:last-child { border: none; margin: 0; padding: 0; }
  
  .item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.6rem;
    .item-main { font-size: 1.15rem; font-weight: 800; color: #1f2937; }
    .item-date { font-size: 0.9rem; color: #9ca3af; font-weight: 500; }
  }
  .item-sub { color: map.get($theme, primary); font-weight: 700; margin-bottom: 0.8rem; font-size: 0.95rem; }
  .item-desc { line-height: 1.7; color: #4b5563; white-space: pre-wrap; font-size: 0.95rem; }
}

.resume-full-content { display: flex; flex-direction: column; gap: 2rem; }

// Student Detail Hub
.student-profile-hub {
  padding: 1rem;
  .profile-content {
    display: grid; gap: 1.5rem;
    .profile-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
    .profile-item {
      display: flex; flex-direction: column; gap: 0.5rem;
      label { font-size: 0.9rem; font-weight: 700; color: #6b7280; }
      .val { font-size: 1.1rem; font-weight: 600; color: #1f2937; }
    }
  }
}
</style>