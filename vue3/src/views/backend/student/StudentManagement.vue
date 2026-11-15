<template>
  <div class="student-management-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>学生管理</h2>
        <div class="header-actions">
          <el-button type="primary" class="aurora-btn" @click="handleAdd">
            <el-icon><Plus /></el-icon>添加学生
          </el-button>
        </div>
      </div>
    </div>

    <!-- 搜索表单 -->
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" ref="searchFormRef" class="aurora-search-bar">
        <el-form-item label="学号" prop="studentNo">
          <el-input v-model="searchForm.studentNo" placeholder="学生学号" clearable />
        </el-form-item>
        <el-form-item label="学院" prop="college">
          <el-input v-model="searchForm.college" placeholder="就读学院" clearable />
        </el-form-item>
        <el-form-item label="专业" prop="major">
          <el-input v-model="searchForm.major" placeholder="专业名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="handleSearch">
            <el-icon><Search /></el-icon> 搜索
          </el-button>
          <el-button class="aurora-btn" @click="resetSearch">
            <el-icon><Refresh /></el-icon> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 表格展示 -->
    <div class="table-wrapper">
      <el-table
        v-loading="loading"
        :data="tableData"
        class="aurora-table"
      >
        <el-table-column prop="studentNo" label="学号" min-width="120" />
        <el-table-column prop="college" label="学院" min-width="150" show-overflow-tooltip />
        <el-table-column prop="major" label="专业" min-width="150" show-overflow-tooltip />
        <el-table-column prop="education" label="学历" width="100">
          <template #default="{ row }">
            <el-tag effect="plain" class="aurora-tag">{{ row.education }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="graduationYear" label="毕业年份" width="100" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="scope">
            <div class="action-btns">
              <el-button link type="primary" class="aurora-btn" @click="handleEdit(scope.row)">
                <el-icon><Edit /></el-icon>编辑
              </el-button>
              <el-button link type="success" class="aurora-btn" @click="handleView(scope.row)">
                <el-icon><View /></el-icon>查看
              </el-button>
              <el-button link type="danger" class="aurora-btn" @click="handleDelete(scope.row)">
                <el-icon><Delete /></el-icon>删除
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

    <!-- 添加/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '录入学生信息' : '更新学生信息'"
      width="600px"
      class="aurora-dialog"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="学号" prop="studentNo">
              <el-input v-model="form.studentNo" placeholder="输入学号" maxlength="20" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学历" prop="education">
              <el-select v-model="form.education" placeholder="选择学历" class="full-width">
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
        
        <el-form-item label="学院" prop="college">
          <el-select
            v-model="form.college"
            placeholder="选择学院"
            class="full-width"
            filterable
            @change="handleCollegeChange"
          >
            <el-option
              v-for="item in collegeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="专业" prop="major">
          <el-select
            v-model="form.major"
            placeholder="选择专业"
            class="full-width"
            :disabled="!form.college"
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
        
        <el-form-item label="毕业年份" prop="graduationYear">
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

        <el-form-item label="关联系统用户" prop="userId" v-if="dialogType === 'add'">
          <el-select v-model="form.userId" placeholder="输入用户名搜索" class="full-width" filterable remote
            :remote-method="searchUsers" :loading="userLoading">
            <el-option v-for="item in userOptions" :key="item.id" :label="item.username" :value="item.id">
              <div class="user-option">
                <span class="uname">{{ item.username }}</span>
                <span class="realname">{{ item.name }}</span>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-btns">
          <el-button @click="dialogVisible = false" round>取消</el-button>
          <el-button type="primary" class="aurora-btn" @click="submitForm" :loading="submitLoading" round>确认提交</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 查看详情弹窗 -->
    <el-dialog v-model="viewDialogVisible" title="学生档案详情" width="500px" class="aurora-dialog">
      <div class="student-profile">
        <div class="profile-item">
          <label>学号</label>
          <div class="val">{{ detailData.studentNo }}</div>
        </div>
        <div class="profile-item">
          <label>学院</label>
          <div class="val">{{ detailData.college }}</div>
        </div>
        <div class="profile-item">
          <label>专业</label>
          <div class="val">{{ detailData.major }}</div>
        </div>
        <div class="profile-item">
          <label>学历</label>
          <div class="val"><el-tag class="aurora-tag">{{ detailData.education }}</el-tag></div>
        </div>
        <div class="profile-item">
          <label>毕业年份</label>
          <div class="val">{{ detailData.graduationYear }}</div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Search, Refresh, Plus, Edit, Delete, View } from '@element-plus/icons-vue';
import request from '@/utils/request';
import { COLLEGE_MAJOR_OPTIONS, EDUCATION_OPTIONS } from '@/constants/studentOptions';

// 表格数据
const tableData = ref([]);
const loading = ref(false);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);

// 搜索表单
const searchFormRef = ref(null);
const searchForm = reactive({
  studentNo: '',
  college: '',
  major: ''
});

// 弹窗表单
const dialogVisible = ref(false);
const dialogType = ref('add'); // add 或 edit
const formRef = ref(null);
const submitLoading = ref(false);
const graduationDate = ref('');

// 查看详情弹窗
const viewDialogVisible = ref(false);
const detailData = ref({});

// 用户选择
const userOptions = ref([]);
const userLoading = ref(false);

const form = reactive({
  id: null,
  studentNo: '',
  college: '',
  major: '',
  education: '',
  graduationYear: null,
  userId: null
});

const collegeOptions = COLLEGE_MAJOR_OPTIONS;
const educationOptions = EDUCATION_OPTIONS;
const majorOptions = computed(() => {
  const currentCollege = collegeOptions.find(item => item.value === form.college);
  return currentCollege?.majors || [];
});

// 表单验证规则
const rules = {
  studentNo: [
    { required: true, message: '请输入学号', trigger: 'blur' },
    { min: 3, max: 20, message: '学号长度在3到20个字符之间', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9]+$/, message: '学号只能包含字母和数字', trigger: 'blur' }
  ],
  college: [
    { required: true, message: '请输入学院', trigger: 'blur' },
    { min: 2, max: 50, message: '学院名称长度在2到50个字符之间', trigger: 'blur' }
  ],
  major: [
    { required: true, message: '请输入专业', trigger: 'blur' },
    { min: 2, max: 50, message: '专业名称长度在2到50个字符之间', trigger: 'blur' }
  ],
  education: [
    { required: true, message: '请选择学历', trigger: 'change' }
  ],
  graduationYear: [
    { required: true, message: '请选择毕业年份', trigger: 'change' }
  ],
  userId: [
    { required: true, message: '请选择关联用户', trigger: 'change' }
  ]
};

// 年份选择处理
const handleYearChange = (val) => {
  if (val) {
    form.graduationYear = parseInt(val);
  } else {
    form.graduationYear = null;
  }
};

const handleCollegeChange = () => {
  if (!majorOptions.value.includes(form.major)) {
    form.major = '';
  }
};

// 获取学生列表
const fetchStudents = async () => {
  loading.value = true;
  try {
    await request.get('/student/page', {
      studentNo: searchForm.studentNo,
      college: searchForm.college,
      major: searchForm.major,
      currentPage: currentPage.value,
      size: pageSize.value
    }, {
      onSuccess: (res) => {
        tableData.value = res.records || [];
        total.value = res.total || 0;
      }
    });
  } finally {
    loading.value = false;
  }
};

// 搜索
const handleSearch = () => {
  currentPage.value = 1;
  fetchStudents();
};

// 重置搜索
const resetSearch = () => {
  if (searchFormRef.value) {
    searchFormRef.value.resetFields();
  }
  currentPage.value = 1;
  fetchStudents();
};

// 处理分页大小变化
const handleSizeChange = (val) => {
  pageSize.value = val;
  fetchStudents();
};

// 处理页码变化
const handleCurrentChange = (val) => {
  currentPage.value = val;
  fetchStudents();
};

// 添加学生
const handleAdd = () => {
  dialogType.value = 'add';
  resetForm();
  dialogVisible.value = true;
};

// 编辑学生
const handleEdit = (row) => {
  dialogType.value = 'edit';
  resetForm();
  Object.assign(form, row);
  graduationDate.value = row.graduationYear ? row.graduationYear.toString() : '';
  dialogVisible.value = true;
};

// 查看学生详情
const handleView = (row) => {
  detailData.value = { ...row };
  viewDialogVisible.value = true;
};

// 删除学生
const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该学生信息吗？此操作不可恢复！', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    request.delete(`/student/${row.id}`, {
      successMsg: '删除成功',
      onSuccess: () => {
        fetchStudents();
      }
    });
  }).catch(() => {});
};

// 重置表单
const resetForm = () => {
  if (formRef.value) {
    formRef.value.resetFields();
  }
  form.id = null;
  form.studentNo = '';
  form.college = '';
  form.major = '';
  form.education = '';
  form.graduationYear = null;
  form.userId = null;
  graduationDate.value = '';
};

// 提交表单
const submitForm = () => {
  formRef.value.validate(async (valid) => {
    if (!valid) {
      return false;
    }
    
    submitLoading.value = true;
    
    try {
      if (dialogType.value === 'add') {
        // 添加
        await request.post('/student', form, {
          successMsg: '添加成功',
          onSuccess: () => {
            dialogVisible.value = false;
            fetchStudents();
          }
        });
      } else {
        // 编辑
        await request.put(`/student/${form.id}`, form, {
          successMsg: '更新成功',
          onSuccess: () => {
            dialogVisible.value = false;
            fetchStudents();
          }
        });
      }
    } finally {
      submitLoading.value = false;
    }
  });
};

// 搜索用户
const searchUsers = async (query) => {
  if (!query || query.length < 1) {
    userOptions.value = [];
    return;
  }
  
  userLoading.value = true;
  try {
    await request.get('/user/page', {
      username: query,
      roleCode: 'STUDENT',
      currentPage: 1,
      size: 10
    }, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        userOptions.value = res.records || [];
      }
    });
  } finally {
    userLoading.value = false;
  }
};

onMounted(() => {
  fetchStudents();
});
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.student-management-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
}

.user-option {
  display: flex;
  justify-content: space-between;
  .realname { color: #9ca3af; font-size: 0.85rem; }
}

.student-profile {
  display: grid;
  gap: 1.5rem;
  padding: 1rem;
  .profile-item {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    label { font-weight: 700; color: #6b7280; font-size: 0.9rem; }
    .val { font-size: 1.1rem; color: #1f2937; font-weight: 600; }
  }
}

.full-width { width: 100% !important; }
</style>
