<template>
  <div class="message-management-container backend-container">
    <div class="aurora-card">
      <div class="card-header">
        <h2>消息通知中心</h2>
        <el-button type="primary" class="aurora-btn" @click="openSendMessageDialog">
          <el-icon><Promotion /></el-icon> 发布新通知
        </el-button>
      </div>
    </div>
    
    <div class="search-panel glass-card">
      <el-form :inline="true" :model="searchForm" class="aurora-search-bar">
        <el-form-item label="消息类型">
          <el-select v-model="searchForm.messageType" placeholder="全部类型" clearable class="status-select">
            <el-option v-for="item in messageTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="接收者">
          <el-input v-model="searchForm.receiverName" placeholder="账号/姓名" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="aurora-btn" @click="fetchMessages">查询</el-button>
          <el-button class="aurora-btn" @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <div class="table-wrapper">
      <el-table v-loading="loading" :data="messages" class="aurora-table">
        <el-table-column prop="messageTypeDesc" label="类型" width="120">
          <template #default="scope">
            <el-tag :type="getMessageTypeTag(scope.row.messageType)" effect="plain" class="aurora-tag">
              {{ scope.row.messageTypeDesc }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip />
        <el-table-column prop="senderName" label="发送方" width="120" />
        <el-table-column prop="receiverName" label="接收方" width="120" />
        <el-table-column prop="createTime" label="时间" width="180" />
        <el-table-column prop="isRead" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.isRead ? 'info' : 'success'" class="aurora-tag">
              {{ scope.row.isRead ? '已读' : '未读' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <div class="action-btns">
              <el-button link type="primary" class="aurora-btn" @click="handleView(scope.row)">
                <el-icon><View /></el-icon> 查看
              </el-button>
              <el-button link type="danger" class="aurora-btn" @click="handleDeleteSingle(scope.row)">
                <el-icon><Delete /></el-icon> 删除
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

    <!-- 发送通知 -->
    <el-dialog v-model="sendMessageDialogVisible" title="系统通知发布" width="600px" class="aurora-dialog">
      <el-form ref="messageFormRef" :model="messageForm" :rules="messageRules" label-position="top">
        <el-form-item label="消息分类" prop="messageType">
          <el-select v-model="messageForm.messageType" placeholder="选择类型" class="full-width">
            <el-option v-for="item in messageTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="通知范围">
          <el-radio-group v-model="receiveType" class="aurora-radio">
            <el-radio label="single">指定用户</el-radio>
            <el-radio label="batch">按角色群发</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item v-if="receiveType === 'single'" label="选择接收人" prop="receiverId">
          <el-select 
            v-model="messageForm.receiverId" 
            filterable 
            remote 
            placeholder="输入关键词搜索用户" 
            :remote-method="searchUsers" 
            :loading="userSearchLoading" 
            class="full-width"
          >
            <el-option v-for="item in userOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        
        <el-form-item v-if="receiveType === 'batch'" label="接收角色" prop="receiverType">
          <el-select v-model="messageForm.receiverType" placeholder="选择角色" class="full-width">
            <el-option label="全体学生" value="STUDENT" />
            <el-option label="全体企业" value="COMPANY" />
            <el-option label="系统全员" value="ALL" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="通知标题" prop="title">
          <el-input v-model="messageForm.title" placeholder="简要概括通知内容" />
        </el-form-item>
        
        <el-form-item label="详细内容" prop="content">
          <el-input v-model="messageForm.content" type="textarea" :rows="6" placeholder="请输入正文..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-btns">
          <el-button @click="sendMessageDialogVisible = false" round>取消</el-button>
          <el-button type="primary" class="aurora-btn" @click="handleSendMessage" :loading="sendLoading" round>发布通知</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 消息详情 -->
    <el-dialog v-model="detailDialogVisible" title="消息详情" width="550px" class="aurora-dialog">
      <div v-if="currentMessage" class="message-detail-box">
        <div class="detail-header">
          <h3>{{ currentMessage.title }}</h3>
          <div class="meta">
            <span>类型: {{ currentMessage.messageTypeDesc }}</span>
            <span>时间: {{ currentMessage.createTime }}</span>
          </div>
        </div>
        <div class="detail-content">
          {{ currentMessage.content }}
        </div>
        <div class="detail-footer">
          <span>发送方: {{ currentMessage.senderName }}</span>
          <span>接收方: {{ currentMessage.receiverName }}</span>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage, ElMessageBox } from 'element-plus';
import request from '@/utils/request';
import { Promotion, Search, View, Delete } from '@element-plus/icons-vue';

const router = useRouter();
const messages = ref([]);
const loading = ref(false);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const searchForm = reactive({ messageType: '', receiverName: '', isRead: '' });

const sendMessageDialogVisible = ref(false);
const detailDialogVisible = ref(false);
const currentMessage = ref(null);
const messageFormRef = ref(null);
const receiveType = ref('single');
const userSearchLoading = ref(false);
const sendLoading = ref(false);
const userOptions = ref([]);
const messageForm = reactive({ messageType: '', receiverId: null, receiverType: '', title: '', content: '' });

const messageRules = {
  messageType: [{ required: true, message: '请选择消息类型', trigger: 'change' }],
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入内容', trigger: 'blur' }],
  receiverId: [{ required: true, message: '请选择接收人', trigger: 'change' }],
  receiverType: [{ required: true, message: '请选择接收角色', trigger: 'change' }]
};

const messageTypeOptions = [
  { value: 'SYSTEM_NOTICE', label: '系统通知' },
  { value: 'INTERVIEW_NOTICE', label: '面试通知' },
  { value: 'RESUME_STATUS', label: '简历状态通知' },
  { value: 'APPLICATION_STATUS', label: '投递状态通知' },
  { value: 'VERIFICATION_NOTICE', label: '认证通知' }
];

const getMessageTypeTag = (t) => ({ 'SYSTEM_NOTICE': 'info', 'INTERVIEW_NOTICE': 'warning', 'RESUME_STATUS': 'success' }[t] || 'primary');

const fetchMessages = async () => {
  loading.value = true;
  request.get('/message/page/admin', {
    messageType: searchForm.messageType,
    receiverName: searchForm.receiverName,
    currentPage: currentPage.value,
    size: pageSize.value
  }, {
    onSuccess: (data) => { messages.value = data.records || []; total.value = data.total || 0 },
    onFinally: () => loading.value = false
  });
};

const resetSearch = () => { Object.assign(searchForm, { messageType: '', receiverName: '', isRead: '' }); fetchMessages(); };
const handleCurrentChange = (p) => { currentPage.value = p; fetchMessages(); };

const handleView = (row) => {
  currentMessage.value = row;
  detailDialogVisible.value = true;
  if (!row.isRead) {
    request.put(`/message/read/${row.id}`, null, {
      onSuccess: () => { row.isRead = 1; }
    });
  }
};

const handleDeleteSingle = (row) => {
  ElMessageBox.confirm('确定删除此消息吗？', '提示', { type: 'warning' }).then(() => {
    request.delete(`/message/${row.id}`, {
      successMsg: '删除成功',
      onSuccess: fetchMessages
    });
  });
};

const openSendMessageDialog = () => { sendMessageDialogVisible.value = true; };

const searchUsers = async (q) => {
  if (!q || q.length < 1) return;
  userSearchLoading.value = true;
  request.get('/user/page', { username: q, currentPage: 1, size: 20 }, {
    onSuccess: (data) => {
      userOptions.value = (data.records || []).map(u => ({ value: u.id, label: `${u.username} (${u.name || '未填写'})` }));
    },
    onFinally: () => userSearchLoading.value = false
  });
};

const handleSendMessage = () => {
  messageFormRef.value.validate(async (v) => {
    if (!v) return;
    sendLoading.value = true;
    const path = receiveType.value === 'single' ? '/message/send' : '/message/batch';
    request.post(path, messageForm, {
      successMsg: '发布成功',
      onSuccess: () => { sendMessageDialogVisible.value = false; fetchMessages(); }
    }).finally(() => sendLoading.value = false);
  });
};

onMounted(fetchMessages);
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.message-management-container {
  .search-panel { padding: 2rem; margin-bottom: 2rem; background: rgba(255, 255, 255, 0.4); }
  .table-wrapper { margin-bottom: 2rem; }
  .pagination-wrapper { display: flex; justify-content: center; }
  .action-btns { display: flex; gap: 8px; }
  .status-select { width: 140px !important; }
}

.message-detail-box {
  padding: 1rem;
  .detail-header {
    border-bottom: 1px solid #f3f4f6;
    padding-bottom: 1.5rem;
    margin-bottom: 1.5rem;
    h3 { font-size: 1.4rem; font-weight: 800; @include aurora-text; margin: 0 0 0.8rem; }
    .meta { display: flex; gap: 1.5rem; color: #9ca3af; font-size: 0.9rem; }
  }
  .detail-content { line-height: 1.8; color: #4b5563; min-height: 150px; font-size: 1.05rem; white-space: pre-wrap; }
  .detail-footer { margin-top: 2rem; padding-top: 1rem; border-top: 1px dashed #f3f4f6; display: flex; justify-content: space-between; color: #6b7280; font-size: 0.9rem; font-weight: 500; }
}

.full-width { width: 100% !important; }
</style>