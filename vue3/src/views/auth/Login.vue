<template>
  <Auth 
    :formData="loginForm" 
    :rules="rules" 
    :loading="loading"
    submitText="登录"
    @submit="handleSubmit"
  >
    <template #auth-tabs>
      <div class="auth-tabs">
        <div class="tab-item active">登录</div>
        <div class="tab-item" @click="goToRegister">注册</div>
      </div>
    </template>

    <template #welcome-text>
      <div class="welcome-title">欢迎回来</div>
      <div class="welcome-subtitle">请登录您的账号</div>
    </template>

    <template #form-items>
      <el-form-item prop="username">
        <el-input 
          v-model="loginForm.username"
          :prefix-icon="User"
          placeholder="请输入用户名">
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input 
          v-model="loginForm.password"
          :prefix-icon="Lock"
          type="password"
          placeholder="请输入密码"
          show-password>
        </el-input>
      </el-form-item>
      <div class="form-extras">
        <el-checkbox v-model="rememberMe">记住我</el-checkbox>
        <router-link to="/forget" class="forget-link">忘记密码？</router-link>
      </div>
    </template>

    <template #auth-links>
      <span>还没有账号？</span>
      <router-link to="/register">立即注册</router-link>
    </template>
  </Auth>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'
import { User, Lock } from '@element-plus/icons-vue'
import Auth from './Auth.vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const formRef = ref(null)
const loading = ref(false)
const rememberMe = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const handleSubmit = (form) => {
  formRef.value = form.value
  loginFormRef.value = form.value
  handleLogin()
}

const goToRegister = () => {
  router.push('/register')
}

const loginFormRef = ref(null)

const handleLogin = () => {
  loginFormRef.value.validate(async valid => {
    if (valid) {
      loading.value = true
      try {
        const res = await request.post("/user/login", loginForm, {
          successMsg: "登录成功",
          showDefaultMsg: true,
          onSuccess: async (data) => {
            userStore.setUserInfo(data)
            
            // 如果是企业用户，检查是否有企业信息
            if (data.roleCode === 'COMPANY') {
              await userStore.loadCompanyInfo()
            }
            
            // 根据返回的角色决定跳转路径
            if (data.roleCode === 'ADMIN') {
              // 直接导航到后台仪表盘
              await router.isReady()
              router.push(route.query.redirect || '/back/dashboard')
            } else {
              // 普通用户登录，直接跳转到前台
              const redirect = route.query.redirect || '/'
              router.push(redirect)
            }
          },
          onError: (error) => {
            console.error('登录失败:', error)
          }
        })
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style lang="scss">
</style>