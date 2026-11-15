<template>
  <div class="interview-management-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>面试流程管理</h2>
      </div>
    </div>

    <!-- 过滤器 -->
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" class="aurora-search-bar">
        <el-form-item label="面试状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable @change="fetchInterviews" class="status-select">
            <el-option label="待确认" :value="0" />
            <el-option label="已确认" :value="1" />
            <el-option label="已完成" :value="2" />
            <el-option label="已取消" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="fetchInterviews">
            <el-icon><Search /></el-icon> 筛选
          </el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <div class="table-wrapper">
      <el-table v-loading="loading" :data="tableData" class="aurora-table">
        <el-table-column prop="studentName" label="候选人" min-width="120" />
        <el-table-column prop="positionName" label="应聘职位" min-width="150" />
        <el-table-column prop="interviewTime" label="面试安排" width="180">
          <template #default="scope">
            <div class="time-cell">
              <el-icon><Timer /></el-icon> {{ formatDateTime(scope.row.interviewTime) }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="interviewAddress" label="地点" min-width="120" show-overflow-tooltip />
        <el-table-column prop="interviewType" label="类型" width="100" />
        <el-table-column label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.interviewStatus)" effect="plain" class="aurora-tag">
              {{ getStatusText(scope.row.interviewStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="结果" width="120">
          <template #default="scope">
            <el-tag v-if="scope.row.interviewStatus === 2" :type="getResultType(scope.row.interviewResult)" effect="dark" class="aurora-tag">
              {{ getResultText(scope.row.interviewResult) }}
            </el-tag>
            <span v-else class="empty-val">-</span>
          </template>
        </el-table-column>
        <el-table-column fixed="right" label="操作" width="220">
          <template #default="scope">
            <div class="action-btns">
              <el-button 
                v-if="(scope.row.interviewStatus === 0 || scope.row.interviewStatus === 1) && userStore.isCompany" 
                type="danger" link class="aurora-btn" @click="handleCancel(scope.row)"
              >取消</el-button>
              <el-button 
                v-if="scope.row.interviewStatus === 1 && userStore.isCompany" 
                type="success" link class="aurora-btn" @click="handleComplete(scope.row)"
              >完成</el-button>
              <el-button type="primary" link class="aurora-btn" @click="handleDetail(scope.row)">
                <el-icon><InfoFilled /></el-icon> 详情
              </el-button>
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

    <!-- 面试详情 -->
    <el-dialog v-model="detailDialogVisible" title="面试记录详情" width="550px" class="aurora-dialog">
      <div v-if="currentInterview" class="interview-profile">
        <div class="profile-row">
          <div class="item">
            <label>候选人</label>
            <span>{{ currentInterview.studentName }}</span>
          </div>
          <div class="item">
            <label>职位</label>
            <span>{{ currentInterview.positionName }}</span>
          </div>
        </div>
        <div class="item">
          <label>面试时间</label>
          <span>{{ formatDateTime(currentInterview.interviewTime) }}</span>
        </div>
        <div class="item">
          <label>面试地点</label>
          <span>{{ currentInterview.interviewAddress }}</span>
        </div>
        <div class="item">
          <label>反馈信息</label>
          <div class="feedback-box">{{ currentInterview.feedback || '暂无反馈' }}</div>
        </div>
      </div>
    </el-dialog>

    <!-- 完成面试 -->
    <el-dialog v-model="completeDialogVisible" title="录入面试结果" width="500px" class="aurora-dialog">
      <el-form :model="completeForm" label-position="top">
        <el-form-item label="面试评定">
          <el-radio-group v-model="completeForm.interviewResult" class="aurora-radio">
            <el-radio :label="1" border>正式通过</el-radio>
            <el-radio :label="2" border>暂不匹配</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="综合评价">
          <el-input v-model="completeForm.feedback" type="textarea" rows="5" placeholder="请输入面试表现评价..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-btns">
          <el-button @click="completeDialogVisible = false" round>取消</el-button>
          <el-button type="primary" class="aurora-btn" @click="submitComplete" round>提交结果</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import request from '@/utils/request';
import { useUserStore } from '@/store/user';
import { Search, Timer, InfoFilled } from '@element-plus/icons-vue';

const userStore = useUserStore();
const loading = ref(false);
const tableData = ref([]);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const searchForm = reactive({ status: null });

const detailDialogVisible = ref(false);
const completeDialogVisible = ref(false);
const currentInterview = ref(null);
const completeForm = reactive({ id: null, interviewResult: 1, feedback: '' });

const fetchInterviews = async () => {
  loading.value = true;
  request.get('/interview/page', {
    status: searchForm.status, currentPage: currentPage.value, size: pageSize.value
  }, {
    onSuccess: (res) => {
      tableData.value = res.records || [];
      total.value = res.total || 0;
    },
    onFinally: () => { loading.value = false; }
  });
};

const handleCurrentChange = (val) => { currentPage.value = val; fetchInterviews(); };
const handleSizeChange = (val) => { pageSize.value = val; fetchInterviews(); };

const formatDateTime = (dt) => {
  if (!dt) return '-';
  const d = new Date(dt);
  return `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2,'0')}-${d.getDate().toString().padStart(2,'0')} ${d.getHours().toString().padStart(2,'0')}:${d.getMinutes().toString().padStart(2,'0')}`;
};

const getStatusText = (s) => ['待确认', '已确认', '已完成', '已取消'][s] || '未知';
const getStatusType = (s) => ['warning', 'primary', 'success', 'info'][s] || 'info';
const getResultText = (r) => ['', '通过', '未通过'][r] || '未知';
const getResultType = (r) => ['', 'success', 'danger'][r] || 'info';

const handleDetail = (row) => { currentInterview.value = row; detailDialogVisible.value = true; };
const handleCancel = (row) => {
  ElMessageBox.confirm('取消面试？', '提示', { type: 'warning' }).then(() => {
    request.put(`/interview/cancel/${row.id}`, { onSuccess: fetchInterviews });
  });
};
const handleComplete = (row) => {
  completeForm.id = row.id; completeForm.interviewResult = 1; completeForm.feedback = '';
  completeDialogVisible.value = true;
};
const submitComplete = async () => {
  if (!completeForm.feedback) return ElMessage.warning('请填写反馈');
  request.put('/interview/complete', completeForm, { onSuccess: () => { completeDialogVisible.value = false; fetchInterviews(); } });
};

onMounted(fetchInterviews);
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.interview-management-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
  .status-select { width: 140px !important; }
}

.time-cell { display: flex; align-items: center; gap: 6px; color: #6366f1; font-weight: 600; }
.empty-val { color: #d1d5db; }

.interview-profile {
  display: grid; gap: 1.5rem; padding: 1rem;
  .profile-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
  .item {
    display: flex; flex-direction: column; gap: 0.5rem;
    label { font-weight: 700; color: #6b7280; font-size: 0.9rem; }
    span { font-size: 1.1rem; color: #1f2937; font-weight: 600; }
    .feedback-box { background: #f9fafb; padding: 1.5rem; border-radius: 12px; line-height: 1.6; }
  }
}
</style> 
