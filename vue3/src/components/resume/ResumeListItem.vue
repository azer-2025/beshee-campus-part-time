<template>
  <el-card class="resume-list-item" shadow="hover">
    <div class="resume-header">
      <div class="resume-title">
        <h3>{{ resume.resumeName }}</h3>
        <el-tag v-if="resume.isDefault" type="primary" size="small">默认</el-tag>
      </div>
      <div class="resume-time">
        <el-tooltip effect="dark" :content="formatDateTime(resume.updateTime || resume.createTime)" placement="top">
          <span>{{ formatTime(resume.updateTime || resume.createTime) }}</span>
        </el-tooltip>
      </div>
    </div>
    
    <div class="resume-actions">
      <el-button type="primary" @click="handleView">查看</el-button>
      <el-button @click="handleEdit">编辑</el-button>
      <el-dropdown @command="handleCommand" trigger="click">
        <el-button type="primary" >
          更多<i class="el-icon-arrow-down el-icon--right"></i>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="preview">预览</el-dropdown-item>
        
            <el-dropdown-item v-if="!resume.isDefault" command="setDefault">设为默认</el-dropdown-item>

            <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </el-card>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { zhCN } from 'date-fns/locale'

const props = defineProps({
  resume: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'view', 'edit', 'preview',
  'setDefault', 'delete'
])

const handleView = () => {
  emit('view', props.resume)
}

const handleEdit = () => {
  emit('edit', props.resume)
}

const handleCommand = (command) => {
  emit(command, props.resume)
}

const formatTime = (dateTime) => {
  if (!dateTime) return ''
  try {
    const date = new Date(dateTime)
    return formatDistanceToNow(date, { addSuffix: true, locale: zhCN })
  } catch (e) {
    return dateTime
  }
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return ''
  try {
    const date = new Date(dateTime)
    return date.toLocaleString()
  } catch (e) {
    return dateTime
  }
}
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.resume-list-item {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.resume-header {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.resume-title {
  display: flex;
  align-items: center;
  gap: 0.8rem;

  h3 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 700;
    color: map.get($theme, text-main);
  }

  .el-tag {
    border-radius: 6px;
    font-weight: 700;
    border: none;
    background: rgba(99, 102, 241, 0.1);
    color: map.get($theme, primary);
  }
}

.resume-time {
  color: map.get($theme, text-light);
  font-size: 0.85rem;
  font-weight: 500;
}

.resume-actions {
  padding: 1.5rem;
  display: flex;
  gap: 0.8rem;
  margin-top: auto;

  .el-button {
    flex: 1;
    height: 40px;
    border-radius: 10px;
    font-weight: 600;
    transition: all 0.3s ease;
    
    &.el-button--primary {
      background: rgba(99, 102, 241, 0.1);
      color: map.get($theme, primary);
      border: none;
      &:hover { background: map.get($theme, primary); color: white; }
    }
    
    &:not(.el-button--primary) {
      background: white;
      border: 1px solid rgba(0,0,0,0.05);
      color: map.get($theme, text-light);
      &:hover { border-color: map.get($theme, primary); color: map.get($theme, primary); }
    }
  }

  .el-dropdown {
    flex: 1;
    .el-button { width: 100%; }
  }
}
</style> 