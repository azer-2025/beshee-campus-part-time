<template>
  <div class="student-interview">
    <el-card class="box-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h2>我的面试</h2>
          <div class="filter-container">
            <el-select style="width: 140px;" v-model="searchForm.status" placeholder="面试状态" clearable @change="fetchInterviews">
              <el-option label="待确认" :value="0" />
              <el-option label="已确认" :value="1" />
              <el-option label="已完成" :value="2" />
              <el-option label="已取消" :value="3" />
            </el-select>
          </div>
        </div>
      </template>
      
      <el-table v-loading="loading" :data="tableData" style="width: 100%">
        <el-table-column prop="companyName" label="企业名称" min-width="150" />
        <el-table-column prop="positionName" label="应聘职位" min-width="120" />
        <el-table-column prop="interviewTime" label="面试时间" width="180">
          <template #default="scope">
            {{ formatDateTime(scope.row.interviewTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="interviewAddress" label="面试地点" min-width="120" />
        <el-table-column prop="interviewType" label="面试类型" width="100" />
        <el-table-column prop="interviewStatus" label="面试状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.interviewStatus)">
              {{ getStatusText(scope.row.interviewStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="interviewResult" label="面试结果" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.interviewStatus === 2" :type="getResultType(scope.row.interviewResult)">
              {{ getResultText(scope.row.interviewResult) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column fixed="right" label="操作" width="220">
          <template #default="scope">
            <div class="action-cell">
              <el-button 
                v-if="scope.row.interviewStatus === 0" 
                type="success" 
                link
                @click="handleConfirm(scope.row)"
                class="action-btn confirm"
              >
                <el-icon><Check /></el-icon> 确认
              </el-button>
              <el-button 
                v-if="scope.row.interviewStatus === 0 || scope.row.interviewStatus === 1" 
                type="danger" 
                link
                @click="handleCancel(scope.row)"
                class="action-btn cancel"
              >
                <el-icon><Close /></el-icon> 取消
              </el-button>
              <el-button 
                type="primary" 
                link
                @click="handleDetail(scope.row)"
                class="action-btn detail"
              >
                <el-icon><InfoFilled /></el-icon> 详情
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination
          v-model="currentPage"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 面试详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="面试详情" width="600px" class="glass-dialog">
      <div v-if="currentInterview" class="interview-detail">
        <div class="detail-item">
          <span class="label">企业名称：</span>
          <span>{{ currentInterview.companyName }}</span>
        </div>
        <div class="detail-item">
          <span class="label">应聘职位：</span>
          <span>{{ currentInterview.positionName }}</span>
        </div>
        <div class="detail-item">
          <span class="label">面试时间：</span>
          <span>{{ formatDateTime(currentInterview.interviewTime) }}</span>
        </div>
        <div class="detail-item">
          <span class="label">面试地点：</span>
          <span>{{ currentInterview.interviewAddress }}</span>
        </div>
        <div class="detail-item">
          <span class="label">面试类型：</span>
          <span>{{ currentInterview.interviewType }}</span>
        </div>
        <div class="detail-item">
          <span class="label">面试状态：</span>
          <span>
            <el-tag :type="getStatusType(currentInterview.interviewStatus)">
              {{ getStatusText(currentInterview.interviewStatus) }}
            </el-tag>
          </span>
        </div>
        <div class="detail-item">
          <span class="label">面试结果：</span>
          <span v-if="currentInterview.interviewStatus === 2">
            <el-tag :type="getResultType(currentInterview.interviewResult)">
              {{ getResultText(currentInterview.interviewResult) }}
            </el-tag>
          </span>
          <span v-else>-</span>
        </div>
        <div class="detail-item">
          <span class="label">面试备注：</span>
          <span>{{ currentInterview.interviewNote || '无' }}</span>
        </div>
        <div v-if="currentInterview.interviewStatus === 2" class="detail-item">
          <span class="label">面试反馈：</span>
          <span>{{ currentInterview.feedback || '无' }}</span>
        </div>
      </div>
    </el-dialog>
    
    <!-- 确认面试对话框 -->
    <el-dialog v-model="confirmDialogVisible" title="确认面试" width="450px" class="glass-dialog">
      <div class="confirm-content">
        <p>确认参加此次面试吗？</p>
        <div class="confirm-info">
          <p><strong>时间：</strong>{{ currentInterview ? formatDateTime(currentInterview.interviewTime) : '' }}</p>
          <p><strong>地点：</strong>{{ currentInterview ? currentInterview.interviewAddress : '' }}</p>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="confirmDialogVisible = false" round>取消</el-button>
          <el-button type="primary" @click="submitConfirm" round>确认参加</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import request from '@/utils/request';
import { Check, Close, InfoFilled } from '@element-plus/icons-vue';

// 数据
const loading = ref(false);
const tableData = ref([]);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const searchForm = reactive({
  status: null
});

// 对话框控制
const detailDialogVisible = ref(false);
const confirmDialogVisible = ref(false);
const currentInterview = ref(null);

// 获取面试列表
const fetchInterviews = async () => {
  loading.value = true;
  try {
    await request.get('/interview/student/page', {
      status: searchForm.status,
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

// 分页处理
const handleSizeChange = (val) => {
  pageSize.value = val;
  fetchInterviews();
};

const handleCurrentChange = (val) => {
  currentPage.value = val;
  fetchInterviews();
};

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return '-';
  const date = new Date(dateTime);
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
};

// 获取状态文本和类型
const getStatusText = (status) => {
  switch (status) {
    case 0: return '待确认';
    case 1: return '已确认';
    case 2: return '已完成';
    case 3: return '已取消';
    default: return '未知';
  }
};

const getStatusType = (status) => {
  switch (status) {
    case 0: return 'warning';
    case 1: return 'primary';
    case 2: return 'success';
    case 3: return 'info';
    default: return 'info';
  }
};

// 获取结果文本和类型
const getResultText = (result) => {
  switch (result) {
    case 0: return '未知';
    case 1: return '通过';
    case 2: return '未通过';
    default: return '未知';
  }
};

const getResultType = (result) => {
  switch (result) {
    case 0: return 'info';
    case 1: return 'success';
    case 2: return 'danger';
    default: return 'info';
  }
};

// 查看详情
const handleDetail = (row) => {
  currentInterview.value = row;
  detailDialogVisible.value = true;
};

// 确认面试
const handleConfirm = (row) => {
  currentInterview.value = row;
  confirmDialogVisible.value = true;
};

// 提交确认面试
const submitConfirm = async () => {
  try {
    await request.put(`/interview/confirm/${currentInterview.value.id}`, null,{
      successMsg: '已确认面试',
      onSuccess: () => {
        confirmDialogVisible.value = false;
        fetchInterviews();
      }
    });
  } catch (error) {
    console.error('确认面试失败', error);
  }
};

// 取消面试
const handleCancel = (row) => {
  ElMessageBox.confirm('确定要取消此次面试吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await request.put(`/interview/cancel/${row.id}`, null,{
        successMsg: '面试已取消',
        onSuccess: () => {
          fetchInterviews();
        }
      });
    } catch (error) {
      console.error('取消面试失败', error);
    }
  }).catch(() => {});
};

// 页面加载时获取数据
onMounted(() => {
  fetchInterviews();
});
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.student-interview {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem 4rem;
  font-family: var(--font-family-base);
}

:deep(.el-card) {
  @include glass-card;
  background: map.get($theme, card-gradient-1);
  padding: 1.5rem;

  .el-card__header {
    border-bottom: 1px solid rgba(0,0,0,0.05);
    padding: 1rem 0 2rem;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;

  h2 {
    font-size: 2.2rem;
    font-weight: 800;
    margin: 0;
    @include aurora-text;
  }
}

.filter-container {
  display: flex;
  gap: 1rem;

  :deep(.el-select) {
    .el-input__wrapper {
      background: white;
      border-radius: 10px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.04) !important;
      border: 1px solid rgba(0,0,0,0.05);
      
      &.is-focus { border-color: map.get($theme, primary); }
    }
  }
}

:deep(.el-table) {
  background: transparent !important;
  --el-table-bg-color: transparent;
  --el-table-tr-bg-color: transparent;
  --el-table-header-bg-color: rgba(99, 102, 241, 0.05);
  
  th.el-table__cell {
    color: map.get($theme, text-main);
    font-weight: 700;
    font-size: 0.95rem;
    padding: 1.2rem 0;
  }
  
  td.el-table__cell {
    color: map.get($theme, text-light);
    font-weight: 500;
    padding: 1.2rem 0;
  }
  
  .el-table__row:hover td.el-table__cell {
    background: rgba(255, 255, 255, 0.5) !important;
  }

  .el-tag {
    border-radius: 6px;
    font-weight: 700;
    border: none;
    padding: 0 10px;
  }
}

.action-cell {
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: flex-start;
}

.action-btn {
  font-weight: 700 !important;
  font-size: 0.9rem !important;
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 0 !important;
  
  &.confirm { color: #10b981 !important; &:hover { color: #059669 !important; } }
  &.cancel { color: #f43f5e !important; &:hover { color: #e11d48 !important; } }
  &.detail { color: map.get($theme, primary) !important; &:hover { color: map.get($theme, accent) !important; } }
  
  .el-icon { font-size: 1.1rem; }
}

.pagination-container {
  margin-top: 2.5rem;
  display: flex;
  justify-content: center;
  
  :deep(.el-pagination) {
    .el-pager li {
      background: white;
      border-radius: 8px;
      margin: 0 4px;
      border: 1px solid rgba(0,0,0,0.05);
      &.is-active { background: map.get($theme, primary); color: white; border: none; }
    }
  }
}

.interview-detail {
  padding: 1rem;
  .detail-item {
    margin-bottom: 1.5rem;
    display: flex;
    font-size: 1rem;
    .label { font-weight: 700; width: 110px; color: map.get($theme, text-main); }
    span:not(.label) { color: map.get($theme, text-light); font-weight: 500; flex: 1; }
  }
}

.confirm-content {
  padding: 1rem;
  p { font-size: 1.1rem; margin-bottom: 1.5rem; color: map.get($theme, text-main); }
  .confirm-info {
    background: rgba(99, 102, 241, 0.05);
    padding: 1.5rem;
    border-radius: 12px;
    p { margin-bottom: 0.5rem; font-size: 1rem; &:last-child { margin-bottom: 0; } }
  }
}

:deep(.el-dialog) {
  border-radius: 24px;
  @include glass-card;
  .el-dialog__header { border-bottom: 1px solid rgba(0,0,0,0.05); padding: 1.5rem 2rem; }
  .el-dialog__title { font-weight: 800; font-size: 1.4rem; @include aurora-text; }
  .el-dialog__footer { padding: 1.5rem 2rem; border-top: 1px solid rgba(0,0,0,0.05); }
}
</style>