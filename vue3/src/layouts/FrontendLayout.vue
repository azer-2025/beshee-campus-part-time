<template>
  <div class="frontend-layout">
    <!-- 顶部导航栏 -->
    <el-header class="glass-header">
      <div class="header-content">
        <div class="logo" @click="router.push('/')">
          <div class="logo-icon">
            <el-icon><Briefcase /></el-icon>
          </div>
          <span class="logo-text">基于SSM的校园兼职系统</span>
        </div>
        
        <el-menu
          mode="horizontal"
          :router="true"
          :default-active="activeIndex"
          class="nav-menu"
          :ellipsis="false"
        >
          <el-menu-item index="/">首页</el-menu-item>
          <el-menu-item index="/positions">职位列表</el-menu-item>
          <el-menu-item index="/companies">企业列表</el-menu-item>
          
          <!-- 学生专属菜单 -->
          <template v-if="isLoggedIn && isStudent">
            <el-menu-item index="/resume">我的简历</el-menu-item>
            <el-menu-item index="/application">投递记录</el-menu-item>
            <el-menu-item index="/interview">我的面试</el-menu-item>
          </template>
          
          <!-- 企业专属菜单 -->
          <template v-if="isLoggedIn && isCompany">
            <el-menu-item class="publish-btn" index="/back/position/form" v-if="hasCompanyInfo">
              <el-icon><Plus /></el-icon> 发布职位
            </el-menu-item>
            <el-menu-item index="/company/profile" v-if="!hasCompanyInfo">
              <el-tag type="warning" effect="dark" round>完善信息</el-tag>
            </el-menu-item>
          </template>
          
          <!-- 管理员专属菜单 -->
          <template v-if="isLoggedIn && isAdmin">
            <el-menu-item index="/back/dashboard">
              <el-tag type="danger" effect="dark" round>后台管理</el-tag>
            </el-menu-item>
          </template>
        </el-menu>
        
        <div class="user-actions">
          <template v-if="isLoggedIn">
            <MessageNotification class="msg-notify" />
            <el-dropdown trigger="click" @command="handleCommand" popper-class="glass-dropdown">
              <div class="user-profile">
                <el-avatar :size="36" :src="avatarUrl" class="user-avatar">
                  {{ (userStore.userInfo?.name || userStore.userInfo?.username || 'U').charAt(0).toUpperCase() }}
                </el-avatar>
                <span class="username">{{ userStore.userInfo?.name || userStore.userInfo?.username }}</span>
                <el-icon class="arrow-icon"><ArrowDown /></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                  <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <template v-else>
            <el-button class="login-btn" text @click="router.push('/login')">登录</el-button>
            <el-button class="register-btn" type="primary" round @click="router.push('/register')">注册</el-button>
          </template>
        </div>
      </div>
    </el-header>

    <!-- 主要内容区域 -->
    <el-main class="main-content">
      <div class="breadcrumb-container" v-if="route.path !== '/'">
        <el-breadcrumb separator="/" class="aurora-breadcrumb">
          <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
          <el-breadcrumb-item v-if="route.meta.title">{{ route.meta.title }}</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      
      <router-view v-slot="{ Component, route }">
        <transition name="fade-scale" mode="out-in">
          <component :is="Component" :key="route.fullPath" />
        </transition>
      </router-view>
    </el-main>

    <!-- 页脚 -->
    <el-footer class="glass-footer">
      <div class="footer-content">
        <p>&copy; {{ new Date().getFullYear() }} 校园招聘系统 · 连接未来</p>
      </div>
    </el-footer>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/user'
import { useRouter, useRoute } from 'vue-router'
import { ArrowDown, Plus, Briefcase } from '@element-plus/icons-vue'
import MessageNotification from '@/components/MessageNotification.vue'

const userStore = useUserStore()
const router = useRouter()
const route = useRoute()
const baseAPI = import.meta.env.VITE_BASE_API || '/api'

const isLoggedIn = computed(() => userStore.isLoggedIn)
const isStudent = computed(() => userStore.isStudent)
const isCompany = computed(() => userStore.isCompany)
const isAdmin = computed(() => userStore.isAdmin)
const hasCompanyInfo = computed(() => userStore.hasCompanyInfo)
const activeIndex = computed(() => route.path)

const avatarUrl = computed(() => {
  const avatar = userStore.userInfo?.avatar
  if (!avatar) return ''
  return avatar.startsWith('http') ? avatar : baseAPI + avatar
})

const handleCommand = (command) => {
  if (command === 'logout') {
    userStore.clearUserInfo()
    router.push('/login')
  } else {
    router.push(`/${command}`)
  }
}
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.frontend-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  // Background handled globally in global.scss
}

.glass-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: 70px;
  padding: 0;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
  
  .header-content {
    max-width: 1280px;
    margin: 0 auto;
    height: 100%;
    display: flex;
    align-items: center;
    padding: 0 2rem;
    justify-content: space-between;
  }
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  
  .logo-icon {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.2rem;
    box-shadow: 0 4px 10px rgba(99, 102, 241, 0.3);
  }
  
  .logo-text {
    font-size: 1.25rem;
    font-weight: 700;
    @include aurora-text;
  }
}

.nav-menu {
  flex: 1;
  margin: 0 3rem;
  background: transparent !important;
  border-bottom: none !important;
  display: flex;
  justify-content: center;

  :deep(.el-menu-item) {
    font-size: 1rem;
    font-weight: 500;
    color: map.get($theme, text-light);
    height: 70px;
    line-height: 70px;
    border-bottom: 3px solid transparent;
    padding: 0 1.5rem;
    transition: all 0.3s ease;
    background: transparent !important;
    
    &:hover {
      color: map.get($theme, primary);
    }
    
    &.is-active {
      color: map.get($theme, primary) !important;
      border-bottom-color: map.get($theme, primary);
      font-weight: 600;
    }
  }
  
  .publish-btn {
    color: map.get($theme, accent) !important;
    font-weight: 600;
  }
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  
  .msg-notify {
    font-size: 1.2rem;
    color: map.get($theme, text-light);
    cursor: pointer;
    transition: color 0.3s;
    
    &:hover {
      color: map.get($theme, primary);
    }
  }
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 20px;
  transition: background 0.3s;
  
  &:hover {
    background: rgba(0, 0, 0, 0.03);
  }
  
  .user-avatar {
    background: linear-gradient(135deg, #a5b4fc, #818cf8);
    font-weight: 600;
    color: white;
  }
  
  .username {
    font-weight: 500;
    color: map.get($theme, text-main);
  }
  
  .arrow-icon {
    font-size: 0.8rem;
    color: map.get($theme, text-light);
  }
}

.login-btn {
  font-weight: 600;
  color: map.get($theme, text-light);
  &:hover { color: map.get($theme, primary); }
}

.register-btn {
  background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, secondary));
  border: none;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  transition: transform 0.2s, box-shadow 0.2s;
  
  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
  }
}

.main-content {
  flex: 1;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  overflow: visible;
}

.breadcrumb-container {
  max-width: 1200px;
  margin: 0 auto 1.5rem;
  padding: 0 2rem;
  
  .aurora-breadcrumb {
    @include aurora-breadcrumb;
  }
}

.glass-footer {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(255, 255, 255, 0.5);
  padding: 2rem 0;
  margin-top: auto;
  
  .footer-content {
    max-width: 1280px;
    margin: 0 auto;
    text-align: center;
    color: map.get($theme, text-light);
    font-size: 0.9rem;
  }
}

// Page Transition
.fade-scale-enter-active,
.fade-scale-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-scale-enter-from {
  opacity: 0;
  transform: scale(0.98);
}

.fade-scale-leave-to {
  opacity: 0;
  transform: scale(1.02);
}
</style>