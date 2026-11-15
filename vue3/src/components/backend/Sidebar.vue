<template>
  <div class="sidebar-container" :class="{ 'is-collapsed': isCollapsed }">
    <div class="logo-wrapper" @click="router.push('/back/dashboard')">
      <div class="logo-icon">
        <el-icon><Briefcase /></el-icon>
      </div>
      <span class="logo-text" v-show="!isCollapsed">基于SSM的校园兼职系统</span>
    </div>
    
    <div class="menu-scroll-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapsed"
        :collapse-transition="false"
        mode="vertical"
        class="aurora-menu"
        router
      >
        <el-menu-item index="/back/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <template #title>仪表盘</template>
        </el-menu-item>
        
        <el-menu-item index="/back/user" v-if="userStore.isAdmin">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/student" v-if="userStore.isAdmin">
          <el-icon><Notebook /></el-icon>
          <template #title>学生管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/company" v-if="userStore.isAdmin">
          <el-icon><OfficeBuilding /></el-icon>
          <template #title>企业管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/position" v-if="userStore.isAdmin || (userStore.isCompany && userStore.hasCompanyInfo)">
          <el-icon><Suitcase /></el-icon>
          <template #title>职位管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/resume" v-if="userStore.isAdmin">
          <el-icon><Document /></el-icon>
          <template #title>简历管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/application" v-if="userStore.isAdmin || userStore.isCompany">
          <el-icon><Promotion /></el-icon>
          <template #title>投递管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/interview" v-if="userStore.isAdmin || userStore.isCompany">
          <el-icon><Calendar /></el-icon>
          <template #title>面试管理</template>
        </el-menu-item>
        
        <el-menu-item index="/back/message" v-if="userStore.isAdmin">
          <el-icon><Bell /></el-icon>
          <template #title>消息通知</template>
        </el-menu-item>
        
        <el-menu-item index="/back/profile">
          <el-icon><UserFilled /></el-icon>
          <template #title>个人中心</template>
        </el-menu-item>
      </el-menu>
    </div>

    <div class="sidebar-footer">
      <div class="footer-btn" @click="router.push('/')">
        <el-icon><Back /></el-icon>
        <span v-show="!isCollapsed">返回前台</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '@/store/app'
import { useUserStore } from '@/store/user'
import { 
  HomeFilled, User, UserFilled, OfficeBuilding, Suitcase, 
  Bell, Notebook, Document, Promotion, Calendar, Briefcase, Back
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()
const userStore = useUserStore()

const isCollapsed = computed(() => appStore.sidebarCollapsed)
const activeMenu = computed(() => route.meta.activeMenu || route.path)
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.sidebar-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border-right: 1px solid rgba(255, 255, 255, 0.5);
  transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  width: 280px;
  overflow: hidden;
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.02);
  z-index: 100;

  &.is-collapsed {
    width: 70px;
    .logo-wrapper { padding: 0; justify-content: center; .logo-icon { margin: 0; } }
  }
}

.logo-wrapper {
  height: 70px;
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 12px;
  cursor: pointer;
  border-bottom: 1px solid rgba(0, 0, 0, 0.03);
  
  .logo-icon {
    width: 32px;
    height: 32px;
    background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.1rem;
    box-shadow: 0 4px 10px rgba(99, 102, 241, 0.2);
  }
  
  .logo-text {
    font-size: 1.1rem;
    font-weight: 800;
    @include aurora-text;
    white-space: nowrap;
  }
}

.menu-scroll-wrapper {
  flex: 1;
  overflow-y: auto;
  padding: 1rem 0.5rem;
  
  &::-webkit-scrollbar { width: 0; }
}

:deep(.aurora-menu) {
  border: none !important;
  background: transparent !important;
  
  .el-menu-item {
    height: 50px;
    line-height: 50px;
    border-radius: 12px;
    margin-bottom: 4px;
    color: map.get($theme, text-light);
    font-weight: 500;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    
    .el-icon {
      font-size: 1.2rem;
      color: map.get($theme, text-light);
      transition: color 0.3s;
    }
    
    &:hover {
      background: rgba(99, 102, 241, 0.05) !important;
      color: map.get($theme, primary);
      .el-icon { color: map.get($theme, primary); }
    }
    
    &.is-active {
      background: linear-gradient(90deg, rgba(99, 102, 241, 0.1) 0%, rgba(99, 102, 241, 0) 100%) !important;
      color: map.get($theme, primary);
      font-weight: 700;
      
      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 15%;
        bottom: 15%;
        width: 4px;
        background: map.get($theme, primary);
        border-radius: 0 4px 4px 0;
      }
      
      .el-icon { color: map.get($theme, primary); }
    }
  }
}

.sidebar-footer {
  padding: 1.5rem 1rem;
  border-top: 1px solid rgba(0, 0, 0, 0.03);
  
  .footer-btn {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px;
    border-radius: 12px;
    color: map.get($theme, text-light);
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 600;
    font-size: 0.95rem;
    
    &:hover {
      background: rgba(0, 0, 0, 0.03);
      color: map.get($theme, text-main);
    }
    
    .el-icon { font-size: 1.2rem; }
  }
}
</style> 