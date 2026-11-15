<template>
  <div class="auth-container">
    <div class="auth-card-wrapper">
      <!-- 左侧品牌宣传区域 -->
      <div class="auth-brand">
        <div class="logo-container">
          <div class="logo-icon">
            <el-icon><Briefcase /></el-icon>
          </div>
        </div>
        <h1 class="brand-title">基于SSM的校园兼职系统</h1>
        <p class="brand-slogan">连接校园精英与优质兼职<br>开启您的职业新篇章</p>
        <div class="brand-illustration">
          <img src="@/assets/auth-illustration.svg" alt="Illustration" />
        </div>
      </div>
      
      <!-- 右侧功能区域 -->
      <div class="auth-form-container">
        <div class="auth-header">
          <slot name="auth-tabs"></slot>
          <div class="welcome-text">
            <slot name="welcome-text"></slot>
          </div>
        </div>
        
        <div class="auth-form-content">
          <el-form :model="formData" :rules="rules" ref="formRef" class="auth-form" size="large">
            <slot name="form-items"></slot>
            
            <el-form-item>
              <button class="submit-btn" :disabled="loading" @click.prevent="handleSubmit">
                <span v-if="!loading">{{ submitText }}</span>
                <el-icon v-else class="is-loading"><Loading /></el-icon>
              </button>
            </el-form-item>
            
            <div class="bottom-links">
              <slot name="auth-links"></slot>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Briefcase, Loading } from '@element-plus/icons-vue'

const props = defineProps({
  formData: {
    type: Object,
    required: true
  },
  rules: {
    type: Object,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  },
  submitText: {
    type: String,
    default: '提交'
  }
})

const formRef = ref(null)
const emit = defineEmits(['submit'])

const handleSubmit = () => {
  formRef.value.validate(valid => {
    if (valid) {
      emit('submit', formRef)
    }
  })
}

defineExpose({
  formRef
})
</script>

<style lang="scss">
@use '@/styles/auth.scss' as auth;
</style> 