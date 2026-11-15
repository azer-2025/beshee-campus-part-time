<template>
  <div class="backend-layout">
    <!-- 侧边栏 -->
    <Sidebar />

    <!-- 主要内容区域 -->
    <div class="main-content">
      <!-- 顶部导航栏 -->
      <Navbar @logout="handleLogout" />

      <!-- 页面内容 -->
      <div class="content-container">
        <router-view v-slot="{ Component, route }">
          <transition name="fade-transform" mode="out-in">
            <component :is="Component" :key="route.fullPath" />
          </transition>
        </router-view>
      </div>
    </div>
    
    <!-- Background Decor -->
    <div class="bg-decor orb-1"></div>
    <div class="bg-decor orb-2"></div>
  </div>
</template>

<script setup>
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import Sidebar from '@/components/backend/Sidebar.vue'
import Navbar from '@/components/backend/Navbar.vue'

const userStore = useUserStore()
const router = useRouter()

const handleLogout = () => {
  userStore.clearUserInfo()
  router.push('/login')
}
</script>

<style lang="scss" scoped>
@use '@/styles/theme.scss' as *;
@use '@/styles/backend.scss';

.backend-layout {
  display: flex;
  height: 100vh;
  width: 100vw;
  background: linear-gradient(-45deg, #f3f4f6, #eef2ff, #fdf2f8, #f0f9ff);
  background-size: 400% 400%;
  animation: gradient-move 15s ease infinite;
  overflow: hidden;
  position: relative;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
  z-index: 10;
}

.content-container {
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
  overflow-x: hidden;
  
  &::-webkit-scrollbar { width: 6px; }
  &::-webkit-scrollbar-thumb { background: rgba(99, 102, 241, 0.1); border-radius: 3px; }
  &::-webkit-scrollbar-track { background: transparent; }
}

.bg-decor {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  z-index: 1;
  opacity: 0.4;
  pointer-events: none;
  
  &.orb-1 {
    top: -10%;
    right: -5%;
    width: 500px;
    height: 500px;
    background: rgba(99, 102, 241, 0.15);
    animation: float-slow 12s infinite ease-in-out;
  }
  
  &.orb-2 {
    bottom: -10%;
    left: 20%;
    width: 400px;
    height: 400px;
    background: rgba(236, 72, 153, 0.1);
    animation: float-slow 15s infinite ease-in-out reverse;
  }
}

// Route Transition
.fade-transform-enter-active,
.fade-transform-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-transform-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>