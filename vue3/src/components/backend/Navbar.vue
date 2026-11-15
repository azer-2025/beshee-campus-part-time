<template>
  <div class="navbar">
    <div class="left-menu">
      <el-icon class="hamburger" :size="20" @click="toggleSidebar">
        <component :is="appStore.sidebarCollapsed ? Expand : Fold" />
      </el-icon>
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/back/dashboard' }">首页</el-breadcrumb-item>
        <el-breadcrumb-item v-if="route.meta.title">{{ route.meta.title }}</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    
    <div class="right-menu">
      <div class="right-menu-item" @click="toggleFullScreen">
        <el-icon :size="20">
          <component :is="isFullscreen ? Aim : FullScreen" />
        </el-icon>
      </div>
      
      <template v-if="!userInfo?.roleCode==='ADMIN'">
        <MessageNotification />
      </template>
      
      <el-dropdown trigger="click">
        <div class="avatar-wrapper">
          <el-avatar :size="32" :src="avatarUrl">
            {{ userInfo?.name?.charAt(0)?.toUpperCase() || userInfo?.username?.charAt(0)?.toUpperCase() || 'U' }}
          </el-avatar>
          <span class="user-name">{{ userInfo?.name || userInfo?.username || '用户' }}</span>
          <el-icon class="el-icon--right">
            <ArrowDown />
          </el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item divided @click="handleLogout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/store/user'
import { useAppStore } from '@/store/app'
import { ElMessageBox } from 'element-plus'
import { Expand, Fold, ArrowDown, User, SwitchButton, FullScreen, Aim } from '@element-plus/icons-vue'
import MessageNotification from '@/components/MessageNotification.vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const baseAPI = import.meta.env.VITE_BASE_API || '/api'
const userInfo = computed(() => userStore.userInfo)
const isFullscreen = ref(false)

const toggleSidebar = () => {
  appStore.toggleSidebar()
}
const avatarUrl = computed(() => {
  const avatar = userInfo.value?.avatar
  if (!avatar) return ''
  return avatar.startsWith('http') ? avatar : baseAPI + avatar
})
const toggleFullScreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
    isFullscreen.value = true
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen()
      isFullscreen.value = false
    }
  }
}

// 监听全屏状态变化
const fullscreenChangeHandler = () => {
  isFullscreen.value = !!document.fullscreenElement
}

document.addEventListener('fullscreenchange', fullscreenChangeHandler)

// 组件卸载时移除事件监听
onUnmounted(() => {
  document.removeEventListener('fullscreenchange', fullscreenChangeHandler)
})



const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(async () => {
    await userStore.logout()
    router.push('/login')
  }).catch(() => {})
}
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.navbar {
  height: 70px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.5);
  position: relative;
  z-index: 50;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);

  .left-menu {
    display: flex;
    align-items: center;
    gap: 20px;

    .hamburger {
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      padding: 10px;
      border-radius: 12px;
      color: map.get($theme, text-light);
      background: rgba(0, 0, 0, 0.02);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      
      &:hover {
        background: rgba(99, 102, 241, 0.1);
        color: map.get($theme, primary);
        transform: scale(1.05);
      }
    }

    :deep(.el-breadcrumb__inner) {
      color: map.get($theme, text-light);
      font-weight: 500;
      
      &.is-link {
        color: map.get($theme, primary);
        &:hover { color: map.get($theme, accent); }
      }
    }
    
    :deep(.el-breadcrumb__item:last-child .el-breadcrumb__inner) {
      color: map.get($theme, text-main);
      font-weight: 700;
    }
  }

  .right-menu {
    display: flex;
    align-items: center;
    gap: 16px;

    .right-menu-item {
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      color: map.get($theme, text-light);
      padding: 10px;
      border-radius: 12px;
      transition: all 0.3s;
      
      &:hover {
        background: rgba(99, 102, 241, 0.1);
        color: map.get($theme, primary);
      }
    }
    
    .avatar-wrapper {
      display: flex;
      align-items: center;
      padding: 6px 12px;
      gap: 10px;
      cursor: pointer;
      border-radius: 100px;
      transition: all 0.3s;
      background: rgba(255, 255, 255, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.8);
      
      &:hover {
        background: white;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        transform: translateY(-1px);
      }
      
      .user-name {
        font-size: 0.95rem;
        font-weight: 600;
        color: map.get($theme, text-main);
      }

      .el-icon {
        color: map.get($theme, text-light);
        font-size: 0.8rem;
        transition: transform 0.3s;
      }

      &:hover .el-icon {
        transform: translateY(2px);
      }
    }
  }
}

@keyframes slideDown {
  from { transform: translateY(-100%); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
</style> 