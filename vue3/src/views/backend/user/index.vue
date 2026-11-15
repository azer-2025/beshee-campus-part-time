<template>
  <div class="user-management">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
        </div>
      </template>
      
      <el-tabs v-model="activeTab">
        <el-tab-pane label="用户列表" name="users">
          <UserList />
        </el-tab-pane>
        <el-tab-pane label="角色管理" name="roles" v-if="hasRoleManagementPermission">
          <RoleList />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useUserStore } from '@/store/user'
import UserList from './UserList.vue'
const userStore = useUserStore()
const activeTab = ref('users')

// 判断是否有角色管理权限
const hasRoleManagementPermission = computed(() => {
  return userStore.isAdmin
})
</script>

<style lang="scss" scoped>
.user-management {
  padding: 0;

  .box-card {
    margin-bottom: 0;
    background: transparent !important;
    box-shadow: none !important;
    border: none !important;
  }
}

:deep(.el-card__body) {
  padding: 0;
}

:deep(.el-tabs__header) {
  margin: 0 0 1rem;
  padding: 0.75rem 1rem 0;
  background: rgba(255, 255, 255, 0.45);
  border-radius: 20px;
  backdrop-filter: blur(14px);
}

:deep(.el-tabs__nav-wrap::after) {
  background-color: rgba(0, 0, 0, 0.05);
}

:deep(.el-tabs__content) {
  overflow: visible;
}
</style> 
