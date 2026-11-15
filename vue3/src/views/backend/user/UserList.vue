<template>
  <div class="user-list-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>用户管理</h2>
        <div class="operation-bar">
          <el-button type="primary" class="aurora-btn" @click="handleAdd">
            <el-icon><Plus /></el-icon> 新增用户
          </el-button>
          <el-button type="danger" class="aurora-btn" :disabled="selectedUsers.length === 0" @click="handleBatchDelete">
            <el-icon><Delete /></el-icon> 批量删除
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索表单 -->
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" class="aurora-search-bar">
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="用户名" clearable />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="searchForm.name" placeholder="真实姓名" clearable />
        </el-form-item>
        <el-form-item label="用户角色">
          <el-select v-model="searchForm.roleCode" placeholder="全部角色" clearable>
            <el-option label="管理员" value="ADMIN" />
            <el-option label="学生" value="STUDENT" />
            <el-option label="企业" value="COMPANY" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="fetchUsers">查询</el-button>
          <el-button class="aurora-btn" @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 用户表格 -->
    <div class="table-wrapper">
      <el-table
        v-loading="loading"
        :data="tableData"
        class="aurora-table"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="name" label="姓名" min-width="120" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column prop="roleCode" label="角色" width="120">
          <template #default="scope">
            <el-tag v-if="scope.row.roleCode === 'ADMIN'" type="danger" class="aurora-tag">管理员</el-tag>
            <el-tag v-else-if="scope.row.roleCode === 'STUDENT'" type="success" class="aurora-tag">学生</el-tag>
            <el-tag v-else-if="scope.row.roleCode === 'COMPANY'" type="warning" class="aurora-tag">企业</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="180">
          <template #default="scope">
            <div class="action-btns">
              <el-button link type="primary" class="aurora-btn" @click="handleEdit(scope.row)">
                <el-icon><Edit /></el-icon> 编辑
              </el-button>
              <el-button link type="danger" class="aurora-btn" @click="handleDelete(scope.row)">
                <el-icon><Delete /></el-icon> 删除
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 分页 -->
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

    <!-- 用户编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增系统用户' : '编辑用户信息'"
      :width="showStudentProfileFields ? '640px' : '500px'"
      top="6vh"
      append-to-body
      destroy-on-close
      class="aurora-dialog user-edit-dialog"
    >
      <el-form
        ref="userFormRef"
        :model="formModel"
        :rules="userFormRules"
        label-position="top"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="user.username">
              <el-input v-model="formModel.user.username" :disabled="dialogType === 'edit'" placeholder="登录账号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="user.name">
              <el-input v-model="formModel.user.name" placeholder="真实姓名" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="邮箱地址" prop="user.email">
          <el-input v-model="formModel.user.email" placeholder="example@domain.com" />
        </el-form-item>
        <el-form-item label="手机号码" prop="user.phone">
          <el-input v-model="formModel.user.phone" placeholder="11位手机号" />
        </el-form-item>
        <el-form-item label="分配角色" prop="user.roleCode">
          <el-select v-model="formModel.user.roleCode" placeholder="请选择角色" class="full-width" @change="handleRoleChange">
            <el-option label="系统管理员" value="ADMIN" />
            <el-option label="学生" value="STUDENT" />
            <el-option label="企业" value="COMPANY" />
          </el-select>
        </el-form-item>
        <el-form-item label="设置密码" prop="user.password" v-if="dialogType === 'add'">
          <el-input v-model="formModel.user.password" type="password" show-password placeholder="不小于6位" />
        </el-form-item>

        <template v-if="showStudentProfileFields">
          <div class="form-section-title">学生档案信息</div>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="学号" prop="studentProfile.studentNo">
                <el-input v-model="formModel.studentProfile.studentNo" placeholder="输入学号" maxlength="20" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="学历" prop="studentProfile.education">
                <el-select v-model="formModel.studentProfile.education" placeholder="选择学历" class="full-width">
                  <el-option
                    v-for="item in educationOptions"
                    :key="item"
                    :label="item"
                    :value="item"
                  />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="学院" prop="studentProfile.college">
            <el-select
              v-model="formModel.studentProfile.college"
              placeholder="选择学院"
              class="full-width"
              filterable
              @change="handleStudentCollegeChange"
            >
              <el-option
                v-for="item in collegeOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="专业" prop="studentProfile.major">
            <el-select
              v-model="formModel.studentProfile.major"
              placeholder="选择专业"
              class="full-width"
              :disabled="!formModel.studentProfile.college"
              filterable
            >
              <el-option
                v-for="item in majorOptions"
                :key="item"
                :label="item"
                :value="item"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="毕业年份" prop="studentProfile.graduationYear">
            <el-date-picker
              v-model="graduationDate"
              type="year"
              placeholder="选择年份"
              format="YYYY"
              value-format="YYYY"
              class="full-width"
              @change="handleYearChange"
            />
          </el-form-item>
        </template>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false" round>取消</el-button>
          <el-button type="primary" class="aurora-btn" @click="submitForm" round>提交保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Delete, Edit, Search } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { COLLEGE_MAJOR_OPTIONS, EDUCATION_OPTIONS } from '@/constants/studentOptions'

const tableData = ref([])
const loading = ref(false)
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const selectedUsers = ref([])

const searchForm = reactive({ username: '', name: '', roleCode: '' })

const resetSearch = () => {
  searchForm.username = ''; searchForm.name = ''; searchForm.roleCode = ''; fetchUsers()
}

const fetchUsers = async () => {
  loading.value = true
  request.get('/user/page', {
    ...searchForm, currentPage: currentPage.value, size: pageSize.value
  }, {
    onSuccess: (res) => { tableData.value = res.records || []; total.value = res.total || 0 },
    onFinally: () => loading.value = false
  })
}

const handleSizeChange = (val) => { pageSize.value = val; fetchUsers() }
const handleCurrentChange = (val) => { currentPage.value = val; fetchUsers() }
const handleSelectionChange = (selection) => { selectedUsers.value = selection }

const dialogVisible = ref(false)
const dialogType = ref('add')
const userFormRef = ref(null)
const graduationDate = ref('')

const createDefaultUser = () => ({ id: null, username: '', name: '', email: '', phone: '', roleCode: '', password: '', status: 1 })
const createDefaultStudentProfile = () => ({ studentNo: '', college: '', major: '', education: '', graduationYear: null })

const formModel = reactive({
  user: createDefaultUser(),
  studentProfile: createDefaultStudentProfile()
})

const showStudentProfileFields = computed(() => formModel.user.roleCode === 'STUDENT')
const collegeOptions = COLLEGE_MAJOR_OPTIONS
const educationOptions = EDUCATION_OPTIONS
const majorOptions = computed(() => {
  const currentCollege = collegeOptions.find(item => item.value === formModel.studentProfile.college)
  return currentCollege?.majors || []
})

const validateStudentField = (message) => (_rule, value, callback) => {
  if (!showStudentProfileFields.value) {
    callback()
    return
  }
  if (value === null || value === undefined || value === '') {
    callback(new Error(message))
    return
  }
  callback()
}

const validateStudentNo = (_rule, value, callback) => {
  if (!showStudentProfileFields.value) {
    callback()
    return
  }
  if (!value) {
    callback(new Error('请输入学号'))
    return
  }
  if (value.length < 3 || value.length > 20) {
    callback(new Error('学号长度在3到20个字符之间'))
    return
  }
  callback()
}

const userFormRules = {
  'user.username': [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  'user.name': [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  'user.email': [{ required: true, message: '请输入邮箱', trigger: 'blur' }],
  'user.roleCode': [{ required: true, message: '请选择角色', trigger: 'change' }],
  'user.password': [{ required: true, message: '请输入密码', trigger: 'blur' }],
  'studentProfile.studentNo': [
    { validator: validateStudentNo, trigger: 'blur' }
  ],
  'studentProfile.college': [{ validator: validateStudentField('请输入学院'), trigger: 'blur' }],
  'studentProfile.major': [{ validator: validateStudentField('请输入专业'), trigger: 'blur' }],
  'studentProfile.education': [{ validator: validateStudentField('请选择学历'), trigger: 'change' }],
  'studentProfile.graduationYear': [{ validator: validateStudentField('请选择毕业年份'), trigger: 'change' }]
}

const resetStudentProfile = () => {
  Object.assign(formModel.studentProfile, createDefaultStudentProfile())
  graduationDate.value = ''
}

const resetDialogForm = () => {
  Object.assign(formModel.user, createDefaultUser())
  resetStudentProfile()
  userFormRef.value?.clearValidate()
}

const handleYearChange = (val) => {
  formModel.studentProfile.graduationYear = val ? parseInt(val, 10) : null
}

const handleRoleChange = (roleCode) => {
  if (roleCode !== 'STUDENT') {
    resetStudentProfile()
  }
}

const handleStudentCollegeChange = (college) => {
  if (!majorOptions.value.includes(formModel.studentProfile.major)) {
    formModel.studentProfile.major = ''
  }
}

const fillStudentProfile = (studentProfile) => {
  Object.assign(formModel.studentProfile, {
    ...createDefaultStudentProfile(),
    ...(studentProfile || {})
  })
  graduationDate.value = formModel.studentProfile.graduationYear ? String(formModel.studentProfile.graduationYear) : ''
}

const handleAdd = () => {
  dialogType.value = 'add'
  resetDialogForm()
  dialogVisible.value = true
}

const handleEdit = async (row) => {
  dialogType.value = 'edit'
  resetDialogForm()
  Object.assign(formModel.user, { ...createDefaultUser(), ...row, password: '' })
  if (row.roleCode === 'STUDENT') {
    try {
      const studentProfile = await request.get(`/student/user/${row.id}`, null, { showDefaultMsg: false })
      fillStudentProfile(studentProfile)
    } catch (_error) {
      resetStudentProfile()
    }
  }
  dialogVisible.value = true
}

const submitForm = () => {
  userFormRef.value.validate(async (valid) => {
    if (!valid) return
    if (dialogType.value === 'add') {
      const payload = {
        user: { ...formModel.user },
        studentProfile: showStudentProfileFields.value ? { ...formModel.studentProfile } : null
      }
      await request.post('/user/admin-create', payload, {
        onSuccess: () => {
          dialogVisible.value = false
          fetchUsers()
        }
      })
    } else {
      const payload = {
        user: { ...formModel.user, password: undefined },
        studentProfile: showStudentProfileFields.value ? { ...formModel.studentProfile } : null
      }
      await request.put(`/user/admin-update/${formModel.user.id}`, payload, {
        onSuccess: () => {
          dialogVisible.value = false
          fetchUsers()
        }
      })
    }
  })
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该用户吗？', '提示', { type: 'warning' }).then(() => {
    request.delete(`/user/delete/${row.id}`, { onSuccess: fetchUsers })
  })
}

const handleBatchDelete = () => {
  const ids = selectedUsers.value.map(user => user.id)
  ElMessageBox.confirm(`确认删除选中的 ${ids.length} 个用户吗？`, '提示', { type: 'warning' }).then(() => {
    request.delete('/user/deleteBatch?ids=' + ids, { onSuccess: fetchUsers })
  })
}

const handleStatusChange = async (row) => {
  request.put(`/user/status/${row.id}`, null, { params: { status: row.status } })
}

onMounted(fetchUsers)
</script>

<style lang="scss" scoped>
.user-list-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
  .form-section-title {
    margin: 0 0 1rem;
    padding-top: 0.5rem;
    border-top: 1px solid rgba(0, 0, 0, 0.06);
    font-size: 1rem;
    font-weight: 700;
    color: #374151;
  }
}
.full-width { width: 100%; }

:deep(.user-edit-dialog) {
  max-width: calc(100vw - 32px);
}

:deep(.user-edit-dialog .el-dialog__body) {
  max-height: calc(100vh - 220px);
  overflow-y: auto;
}
</style> 
