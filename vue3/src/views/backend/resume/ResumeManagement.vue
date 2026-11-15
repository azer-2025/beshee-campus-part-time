<template>
  <div class="resume-management-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>简历档案管理</h2>
      </div>
    </div>

    <!-- 搜索表单 -->
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" class="aurora-search-bar">
        <el-form-item label="模糊搜索">
          <el-input v-model="searchForm.keyword" placeholder="学生姓名 / 简历名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="search">
            <el-icon><Search /></el-icon> 搜索
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 数据表格 -->
    <div class="table-wrapper">
      <el-table :data="resumeList" class="aurora-table" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="studentName" label="学生姓名" min-width="120" />
        <el-table-column prop="resumeName" label="简历标题" min-width="180" />
        <el-table-column prop="createTime" label="创建日期" width="180" />
        <el-table-column prop="updateTime" label="最后更新" width="180" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <div class="action-btns">
              <el-button link type="primary" class="aurora-btn" @click="viewDetail(scope.row.id)">
                <el-icon><View /></el-icon> 预览
              </el-button>
              <el-button link type="danger" class="aurora-btn" @click="deleteResume(scope.row.id)">
                <el-icon><Delete /></el-icon> 删除
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>

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

    <!-- 简历详情弹窗 -->
    <el-dialog v-model="resumeDialogVisible" title="简历档案详情" width="1000px" class="aurora-dialog">
      <div v-loading="resumeLoading" class="resume-preview-hub">
        <div v-if="resumeData" class="resume-body">
          <div class="resume-main-header">
            <div class="title-left">
              <h1>{{ resumeData.studentName }}的个人简历</h1>
              <p class="resume-subtitle">{{ resumeData.resumeName }}</p>
            </div>
            <el-tag effect="dark" round class="aurora-tag status-tag">在线简历</el-tag>
          </div>
          
          <div class="resume-grid">
            <!-- 基本信息 -->
            <div class="glass-card resume-block">
              <div class="block-title"><el-icon><UserFilled /></el-icon> 基本资料</div>
              <el-descriptions :column="2" border size="small" class="custom-descriptions" v-if="resumeData.resumeContent.basicInfo">
                <el-descriptions-item label="姓名">{{ resumeData.resumeContent.basicInfo.name }}</el-descriptions-item>
                <el-descriptions-item label="性别">{{ resumeData.resumeContent.basicInfo.gender }}</el-descriptions-item>
                <el-descriptions-item label="出生">{{ resumeData.resumeContent.basicInfo.birthDate }}</el-descriptions-item>
                <el-descriptions-item label="邮箱">{{ resumeData.resumeContent.basicInfo.email }}</el-descriptions-item>
                <el-descriptions-item label="电话">{{ resumeData.resumeContent.basicInfo.phone }}</el-descriptions-item>
                <el-descriptions-item label="住址">{{ resumeData.resumeContent.basicInfo.address }}</el-descriptions-item>
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
          
          <div class="resume-full-content">
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { UserFilled, Aim, School, Briefcase, Search, View, Delete } from '@element-plus/icons-vue'

const searchForm = ref({ keyword: '' })
const resumeList = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const loadData = () => {
  loading.value = true
  const params = {
    currentPage: currentPage.value,
    size: pageSize.value,
    keyword: searchForm.value.keyword
  }
  request.get('/resume/admin/page', params, {
    onSuccess: (data) => {
      resumeList.value = data.records || []
      total.value = data.total || 0
    },
    onFinally: () => { loading.value = false }
  })
}

const search = () => { currentPage.value = 1; loadData() }
const handleSizeChange = (val) => { pageSize.value = val; loadData() }
const handleCurrentChange = (val) => { currentPage.value = val; loadData() }

const resumeDialogVisible = ref(false)
const resumeLoading = ref(false)
const resumeData = ref(null)

const viewDetail = (id) => {
  resumeLoading.value = true
  resumeDialogVisible.value = true
  request.get(`/resume/${id}`, null, {
    onSuccess: (data) => {
      if (data.resumeContent && typeof data.resumeContent === 'string') {
        try { data.resumeContent = JSON.parse(data.resumeContent) } catch (e) { console.error(e) }
      }
      resumeData.value = data
    },
    onFinally: () => { resumeLoading.value = false }
  })
}

const deleteResume = (id) => {
  ElMessageBox.confirm('确定删除此简历吗？', '警告', { type: 'warning' }).then(() => {
    request.delete(`/resume/${id}`, { onSuccess: () => loadData() })
  })
}

onMounted(loadData)
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.resume-management-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
}

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
  animation: none; // Disable entry animation for dialog content
  
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
    width: 100px;
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
  
  .item-sub { 
    color: map.get($theme, primary); 
    font-weight: 700; 
    margin-bottom: 0.8rem; 
    font-size: 0.95rem;
  }
  
  .item-desc { 
    line-height: 1.7; 
    color: #4b5563; 
    white-space: pre-wrap;
    font-size: 0.95rem;
  }
}

.resume-full-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}
</style> 
