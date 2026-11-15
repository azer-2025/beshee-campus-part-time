<template>
  <div class="resume-list-page">
    <div class="page-header">
      <h1>我的简历</h1>
      <div class="header-actions">
        <el-button type="primary" @click="handleCreate">新建简历</el-button>
      </div>
    </div>
    
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="3" animated />
    </div>
    
    <div v-else-if="resumeList.length === 0" class="empty-container">
      <el-empty description="暂无简历，快去创建一份简历吧！">
        <el-button type="primary" @click="handleCreate">新建简历</el-button>
      </el-empty>
    </div>
    
    <div v-else class="resume-list">
      <resume-list-item
        v-for="resume in resumeList"
        :key="resume.id"
        :resume="resume"
        @view="handleView"
        @edit="handleEdit"
        @preview="handleView" 
        @setDefault="handleSetDefault"
        @polish="handlePolish"
        @delete="handleDelete"
      />
    </div>
    
    <!-- 创建简历对话框 -->
    <el-dialog
      title="新建简历"
      v-model="createDialogVisible"
      width="500px"
    >
      <el-form :model="createForm" ref="createFormRef" label-width="120px" :rules="rules">
        <el-form-item label="简历名称" prop="resumeName">
          <el-input v-model="createForm.resumeName" placeholder="请输入简历名称" />
        </el-form-item>
        <el-form-item label="是否设为默认">
          <el-switch v-model="createForm.isDefault" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="createDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitCreateForm" :loading="submitting">创建</el-button>
        </div>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ResumeListItem from '@/components/resume/ResumeListItem.vue'
import { isMissingStudentProfileError, promptCompleteStudentProfile } from '@/utils/studentProfile'
import {
  getResumeList,
  createResume,
  deleteResume,
  setDefaultResume,

} from '@/utils/resumeApi'

const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const resumeList = ref([])

// 对话框显示状态
const createDialogVisible = ref(false)


// 表单数据
const createForm = ref({
  resumeName: '',
  isDefault: false
})


// 选中的模板和简历
const selectedResume = ref(null)

// 表单校验规则
const rules = {
  resumeName: [
    { required: true, message: '请输入简历名称', trigger: 'blur' },
    { max: 50, message: '简历名称不能超过50个字符', trigger: 'blur' }
  ]
}



// 页面初始化时加载简历列表
onMounted(() => {
  fetchResumeList()
})

// 获取简历列表
const fetchResumeList = () => {
  loading.value = true
  getResumeList({
    showDefaultMsg: false,
    onSuccess: (res) => {
      resumeList.value = res || []
    },
    onError: async (error) => {
      if (isMissingStudentProfileError(error)) {
        resumeList.value = []
        await promptCompleteStudentProfile(router, router.currentRoute.value.fullPath)
        return
      }
      ElMessage.error('获取简历列表失败')
    },
    onFinally: () => {
      loading.value = false
    },

  })
}

// 新建简历
const handleCreate = () => {
  createForm.value = {
    resumeName: '',
    isDefault: false
  }
  createDialogVisible.value = true
}

// 查看简历
const handleView = (resume) => {
  router.push(`/resume/preview/${resume.id}`)
}

// 编辑简历
const handleEdit = (resume) => {
  router.push(`/resume/edit/${resume.id}`)
}




// 设置默认简历
const handleSetDefault = (resume) => {
  setDefaultResume(resume.id, {
    successMsg: '设置成功',
    onSuccess: () => {
      fetchResumeList()
    }
  })
}


// AI润色简历
const handlePolish = (resume) => {
  router.push(`/resume/polish/${resume.id}`)
}

// 删除简历
const handleDelete = (resume) => {
  ElMessageBox.confirm('确定要删除此简历吗？该操作不可恢复', '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    deleteResume(resume.id, {
      successMsg: '删除成功',
      onSuccess: () => {
        fetchResumeList()
      }
    })
  }).catch(() => {})
}

// 提交创建简历表单
const submitCreateForm = () => {
  submitting.value = true
  createResume(createForm.value, {
    successMsg: '创建成功',
    onSuccess: (res) => {
      createDialogVisible.value = false
      router.push(`/resume/edit/${res}`)
    },
    onError: () => {
      ElMessage.error('创建简历失败')
    },
    onFinally: () => {
      submitting.value = false
    }
  })
}




</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.resume-list-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem 4rem;
}

.page-header {
  @include page-header-glass;
  display: flex;
  justify-content: space-between;
  align-items: center;
  text-align: left;
  
  h1 { margin: 0; }
  
  .header-actions .el-button {
    height: 48px;
    padding: 0 2rem;
    border-radius: 12px;
    font-weight: 700;
    background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
    border: none;
    box-shadow: 0 8px 20px rgba(99, 102, 241, 0.3);
  }
}

.resume-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 2rem;
  margin-top: 2rem;

  :deep(.resume-list-item) {
    @include glass-card;
    background: map.get($theme, card-gradient-1);
    border-radius: 24px;
    overflow: hidden;
    padding: 0;
    @include hover-lift;

    .resume-header {
      padding: 2rem;
      background: rgba(255, 255, 255, 0.3);
      border-bottom: 1px solid rgba(0,0,0,0.03);
      
      .resume-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: map.get($theme, text-main);
        margin-bottom: 0.5rem;
      }
      .resume-meta { color: map.get($theme, text-light); font-weight: 500; }
    }

    .resume-content {
      padding: 2rem;
      
      .resume-info {
        margin-bottom: 1.5rem;
        color: map.get($theme, text-light);
        font-size: 0.95rem;
        line-height: 1.6;
      }

      .resume-actions {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 1rem;

        .el-button {
          margin: 0;
          height: 40px;
          border-radius: 10px;
          font-weight: 600;
          
          &.el-button--primary {
            background: rgba(99, 102, 241, 0.1);
            color: map.get($theme, primary);
            border: none;
            &:hover { background: map.get($theme, primary); color: white; }
          }
          
          &.el-button--success {
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            border: none;
            &:hover { background: #059669; color: white; }
          }
          
          &.el-button--danger {
            background: rgba(244, 63, 94, 0.05);
            color: #f43f5e;
            border: none;
            &:hover { background: #f43f5e; color: white; }
          }
        }
      }
    }

    .resume-status {
      position: absolute;
      top: 1.5rem;
      right: 1.5rem;
      .el-tag { border-radius: 8px; font-weight: 700; border: none; padding: 0 12px; }
    }
  }
}

:deep(.el-dialog) {
  border-radius: 24px;
  @include glass-card;
  .el-dialog__header { border-bottom: 1px solid rgba(0,0,0,0.05); padding: 1.5rem 2rem; }
}
</style> 
