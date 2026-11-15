<template>
  <div class="position-form-page backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <div class="header-left">
          <el-button @click="goBack" circle class="back-btn">
            <el-icon><ArrowLeft /></el-icon>
          </el-button>
          <h2>{{ isEdit ? '职位资料编辑' : '发布新的职位' }}</h2>
        </div>
      </div>
    </div>

    <div class="form-wrapper glass-card" v-loading="loading">
      <el-form 
        ref="formRef"
        :model="positionForm"
        :rules="rules"
        label-position="top"
        class="aurora-form"
      >
        <div class="form-section">
          <h3 class="section-title"><el-icon><Edit /></el-icon> 核心信息</h3>
          <el-row :gutter="30">
            <el-col :span="12">
              <el-form-item label="职位名称" prop="positionName">
                <el-input v-model="positionForm.positionName" placeholder="例如：高级Java工程师" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="职位类型" prop="positionType">
                <el-select v-model="positionForm.positionType" placeholder="选择类型" class="full-width">
                  <el-option label="全职" value="全职" />
                  <el-option label="兼职" value="兼职" />
                  <el-option label="实习" value="实习" />
                  <el-option label="校招" value="校招" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="30">
            <el-col :span="12">
              <el-form-item label="职位类别" prop="positionCategory">
                <el-select v-model="positionForm.positionCategory" placeholder="选择类别" class="full-width">
                  <el-option v-for="cat in ['技术','产品','设计','运营','市场','销售','财务','人事','行政','法务','其他']" :key="cat" :label="cat" :value="cat" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="工作城市" prop="workAddress">
                <el-input v-model="positionForm.workAddress" placeholder="例如：北京-海淀" />
              </el-form-item>
            </el-col>
          </el-row>
        </div>

        <div class="form-section">
          <h3 class="section-title"><el-icon><Money /></el-icon> 薪资与要求</h3>
          <el-row :gutter="30">
            <el-col :span="12">
              <el-form-item label="薪资范围 (最低 - 最高) 单位: K" prop="salaryMin">
                <div class="salary-inputs">
                  <el-input-number 
                    v-model="displaySalaryMin" 
                    :min="0" 
                    :step="1" 
                    controls-position="right" 
                    class="salary-num" 
                    placeholder="最低"
                  />
                  <span class="sep">至</span>
                  <el-input-number 
                    v-model="displaySalaryMax" 
                    :min="0" 
                    :step="1" 
                    controls-position="right" 
                    class="salary-num" 
                    placeholder="最高"
                  />
                </div>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="学历要求" prop="educationRequirement">
                <el-select v-model="positionForm.educationRequirement" placeholder="选择要求" class="full-width">
                  <el-option v-for="edu in ['不限','大专','本科','硕士','博士']" :key="edu" :label="edu" :value="edu" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="30">
            <el-col :span="12">
              <el-form-item label="经验要求" prop="experienceRequirement">
                <el-select v-model="positionForm.experienceRequirement" placeholder="选择要求" class="full-width">
                  <el-option v-for="exp in ['不限','应届生','1年以内','1-3年','3-5年','5-10年','10年以上']" :key="exp" :label="exp" :value="exp" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="招聘人数" prop="positionCount">
                <el-input-number v-model="positionForm.positionCount" :min="1" :max="999" class="full-width" />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-form-item label="截止日期" prop="deadline">
            <el-date-picker v-model="positionForm.deadline" type="date" placeholder="选择日期" class="full-width" />
          </el-form-item>
        </div>

        <div class="form-section">
          <h3 class="section-title"><el-icon><Document /></el-icon> 详细说明</h3>
          <el-form-item label="职位描述" prop="positionDescription">
            <el-input v-model="positionForm.positionDescription" type="textarea" :rows="6" placeholder="请输入岗位职责和详细说明..." />
          </el-form-item>

          <el-form-item label="任职要求" prop="positionRequirement">
            <el-input v-model="positionForm.positionRequirement" type="textarea" :rows="6" placeholder="请输入技能要求和必备素质..." />
          </el-form-item>
        </div>

        <div class="form-footer">
          <el-button type="primary" class="aurora-btn submit-btn" @click="handleSubmit" :loading="submitting">
            {{ isEdit ? '保存更新' : '立即发布' }}
          </el-button>
          <el-button @click="resetForm" round>重置表单</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Edit, Money, Document } from '@element-plus/icons-vue'
import { createPosition, getPositionDetail, updatePosition } from '@/api/position'

const router = useRouter()
const route = useRoute()
const positionId = route.params.id
const isEdit = computed(() => !!positionId)
const formRef = ref(null)
const loading = ref(false)
const submitting = ref(false)

const displaySalaryMin = computed({
  get: () => positionForm.salaryMin / 1000,
  set: (val) => positionForm.salaryMin = val * 1000
})

const displaySalaryMax = computed({
  get: () => positionForm.salaryMax / 1000,
  set: (val) => positionForm.salaryMax = val * 1000
})

const positionForm = reactive({
  positionName: '', positionType: '', positionCategory: '', workAddress: '',
  salaryMin: 0, salaryMax: 0, educationRequirement: '', experienceRequirement: '',
  positionCount: 1, deadline: '', positionDescription: '', positionRequirement: ''
})

const rules = {
  positionName: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  positionType: [{ required: true, message: '请选择类型', trigger: 'change' }],
  positionCategory: [{ required: true, message: '请选择类别', trigger: 'change' }],
  workAddress: [{ required: true, message: '请输入地点', trigger: 'blur' }],
  salaryMin: [{ type: 'number', required: true, message: '最低薪资', trigger: 'blur' }],
  deadline: [{ required: true, message: '选择截止日期', trigger: 'change' }],
  positionDescription: [{ required: true, message: '详细描述职位', trigger: 'blur' }]
}

const goBack = () => router.push('/back/position')
const resetForm = () => formRef.value.resetFields()

const handleSubmit = async () => {
  if (submitting.value) return
  try {
    await formRef.value.validate()
    if (positionForm.salaryMin > positionForm.salaryMax) return ElMessage.warning('最低薪资不能大于最高薪资')
    submitting.value = true
    if (isEdit.value) {
      await updatePosition(positionId, positionForm, { onSuccess: () => router.push('/back/position') })
    } else {
      await createPosition(positionForm, { onSuccess: () => router.push('/back/position') })
    }
  } catch (error) { console.error(error) } finally { submitting.value = false }
}

onMounted(async () => {
  if (isEdit.value) {
    loading.value = true
    await getPositionDetail(positionId, {
      onSuccess: (data) => Object.assign(positionForm, data),
      onFinally: () => loading.value = false
    })
  }
})
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.position-form-page {
  max-width: 1000px;
  margin: 0 auto;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
  .back-btn { border: none; background: rgba(0,0,0,0.05); &:hover { background: rgba(99, 102, 241, 0.1); color: #6366f1; } }
}

.form-wrapper { padding: 3rem; background: white; border-radius: 24px; }

.section-title {
  font-size: 1.25rem; font-weight: 800; color: map.get($theme, primary);
  display: flex; align-items: center; gap: 10px; margin: 2rem 0 1.5rem;
  &:first-child { margin-top: 0; }
}

.salary-inputs {
  display: flex; align-items: center; gap: 1rem;
  .salary-num { flex: 1; }
  .sep { font-weight: 700; color: #9ca3af; }
}

.form-footer {
  margin-top: 4rem; padding-top: 2rem; border-top: 1px solid rgba(0,0,0,0.05);
  display: flex; gap: 1.5rem;
  .submit-btn { padding: 0 4rem; height: 50px; border-radius: 14px !important; }
}

.full-width { width: 100% !important; }
</style>