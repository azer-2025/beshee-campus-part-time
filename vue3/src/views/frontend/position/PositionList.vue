<template>
  <div class="position-list-page">
    <div class="search-hero">
      <div class="hero-content">
        <h2 class="hero-title">校园兼职，让青春更出彩</h2>
        <p class="hero-subtitle">发现优质校内校外兼职机遇，开启勤工俭学新篇章</p>
        
        <!-- Mega Search Bar -->
        <div class="mega-search-container">
          <div class="search-input-wrapper glass-card">
            <el-icon class="search-icon"><Search /></el-icon>
            <input 
              v-model="searchForm.keyword" 
              type="text" 
              placeholder="搜索职位名称、公司或关键词..." 
              @keyup.enter="handleSearch"
            />
            <button class="mega-search-btn" @click="handleSearch">
              <span>立即搜索</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Interactive Filter Panel -->
    <div class="filter-hub-container">
      <div class="filter-hub glass-card">
        <div class="filter-row">
          <div class="filter-item">
            <span class="filter-label">职位类型</span>
            <el-select v-model="searchForm.positionType" placeholder="不限类型" clearable class="aurora-select">
              <el-option v-for="item in positionTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>

          <div class="filter-item">
            <span class="filter-label">工作城市</span>
            <el-input v-model="searchForm.workAddress" placeholder="城市名称" clearable class="aurora-input">
              <template #prefix><el-icon><Location /></el-icon></template>
            </el-input>
          </div>

          <div class="filter-item salary-filter">
            <span class="filter-label">薪资范围 (K)</span>
            <div class="salary-slider-wrapper">
              <el-slider
                v-model="salaryRange"
                range
                :min="0"
                :max="100"
                :format-tooltip="val => val + 'K'"
                class="aurora-slider"
                @change="handleSalaryChange"
              />
              <div class="salary-text-range">
                {{ salaryRange[0] }}K - {{ salaryRange[1] }}K+
              </div>
            </div>
          </div>

          <div class="filter-actions">
            <el-button class="reset-btn" @click="resetSearch" link>
              <el-icon><RefreshRight /></el-icon> 重置筛选
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- Content Section -->
    <div class="results-layout">
      <div class="results-header" v-if="!loading">
        <div class="results-count">
          为您匹配到 <strong>{{ total }}</strong> 个热门职位
        </div>
        <div class="sort-options">
          <span class="active">最新发布</span>
          <span>综合推荐</span>
        </div>
      </div>

      <div v-loading="loading" class="positions-grid">
        <template v-if="positionList.length > 0">
          <div 
            v-for="position in positionList" 
            :key="position.id" 
            class="position-card-modern"
            @click="viewPositionDetail(position.id)"
          >
            <div class="card-inner">
              <div class="card-header">
                <div class="pos-top">
                  <h3 class="pos-title">{{ position.positionName }}</h3>
                  <span class="pos-salary">{{ formatSalaryDisplay(position.salaryMin, position.salaryMax) }}</span>
                </div>
                <div class="company-row">
                  <span class="company-name">{{ position.companyName }}</span>
                  <div class="company-logo">
                    <el-avatar :size="40" shape="square" :src="position.companyLogo ? baseAPI + position.companyLogo : ''">
                      <el-icon><OfficeBuilding /></el-icon>
                    </el-avatar>
                  </div>
                </div>
              </div>

              <div class="pos-meta">
                <div class="meta-pill"><el-icon><Location /></el-icon>{{ position.workAddress || '不限' }}</div>
                <div class="meta-pill"><el-icon><School /></el-icon>{{ position.educationRequirement || '不限' }}</div>
                <div class="meta-pill"><el-icon><Timer /></el-icon>{{ position.experienceRequirement || '应届' }}</div>
              </div>

              <div class="pos-tags">
                <span class="tag type-tag">{{ position.positionType || '全职' }}</span>
                <span class="tag cat-tag" v-if="position.positionCategory">{{ position.positionCategory }}</span>
              </div>

              <div class="card-footer">
                <span class="publish-date">{{ DateUtils.formatDateTime(position.createTime) }} 发布</span>
                <el-button class="quick-apply-btn" type="primary" size="small" @click.stop="applyPosition(position)">
                  立即申请
                </el-button>
              </div>
            </div>
          </div>
        </template>
        <el-empty v-else description="暂无匹配职位" class="aurora-empty" />
      </div>

      <!-- Pagination -->
      <div class="pagination-container" v-if="total > 0">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[12, 24, 48]"
          layout="total, sizes, prev, pager, next"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          class="aurora-pagination"
        />
      </div>
    </div>

    <!-- Apply Dialog -->
    <el-dialog v-model="applyDialogVisible" title="确认投递" width="460px" class="aurora-dialog">
      <div v-if="selectedPosition" class="apply-box">
        <div class="target-job">
          <h4>{{ selectedPosition.positionName }}</h4>
          <p>{{ selectedPosition.companyName }}</p>
        </div>
        <el-form label-position="top">
          <el-form-item label="选择投递简历">
            <el-select v-model="applyForm.resumeId" placeholder="请选择您的简历" class="full-width">
              <el-option v-for="resume in resumeList" :key="resume.id" :label="resume.resumeName" :value="resume.id" />
            </el-select>
          </el-form-item>
        </el-form>
        <el-alert v-if="!resumeList.length" title="暂无简历" type="warning" show-icon :closable="false">
          您需要先 <el-link type="primary" @click="goToCreateResume">完善简历</el-link> 才能投递。
        </el-alert>
      </div>
      <template #footer>
        <div class="dialog-btns">
          <el-button @click="applyDialogVisible = false" round>再想想</el-button>
          <el-button type="primary" @click="submitApplication" :disabled="!applyForm.resumeId" round>确认投递</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'
import { Search, OfficeBuilding, Location, School, Timer, RefreshRight } from '@element-plus/icons-vue'
import DateUtils from '@/utils/dateUtils'
import { ensureStudentProfile, isMissingStudentProfileError, promptCompleteStudentProfile } from '@/utils/studentProfile'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const baseAPI = import.meta.env.VITE_BASE_API || '/api'

const positionList = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)

const salaryRange = ref([0, 100])

const searchForm = reactive({
  keyword: route.query.keyword || '',
  positionType: '',
  workAddress: '',
  salaryMin: 0,
  salaryMax: 100000,
  companyId: route.query.companyId || null
})

const positionTypeOptions = [
  { value: '全职', label: '全职' }, { value: '兼职', label: '兼职' },
  { value: '实习', label: '实习' }, { value: '校招', label: '校招' }
]

const handleSalaryChange = (val) => {
  searchForm.salaryMin = val[0] * 1000
  searchForm.salaryMax = val[1] === 100 ? null : val[1] * 1000
  handleSearch()
}

const fetchPositions = () => {
  loading.value = true
  const params = {
    positionName: searchForm.keyword,
    positionType: searchForm.positionType,
    workAddress: searchForm.workAddress,
    salaryMin: searchForm.salaryMin,
    salaryMax: searchForm.salaryMax,
    status: 1,
    companyId: searchForm.companyId,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/position/page', params, {
    onSuccess: (res) => {
      positionList.value = res.records || []
      total.value = res.total || 0
    },
    onFinally: () => { loading.value = false }
  })
}

// Dialog & Apply
const applyDialogVisible = ref(false)
const selectedPosition = ref(null)
const resumeList = ref([])
const applyForm = reactive({ resumeId: '', positionId: '' })

const fetchUserResumes = () => {
  if (userStore.isLoggedIn && userStore.isStudent) {
    request.get('/resume/list', {}, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        resumeList.value = res || []
      },
      onError: async (error) => {
        if (isMissingStudentProfileError(error)) {
          resumeList.value = []
          await promptCompleteStudentProfile(router, route.fullPath)
        }
      }
    })
  }
}

const handleSearch = () => { currentPage.value = 1; fetchPositions() }
const resetSearch = () => {
  searchForm.keyword = '';
  searchForm.positionType = '';
  searchForm.workAddress = '';
  searchForm.salaryMin = 0;
  searchForm.salaryMax = 100000;
  salaryRange.value = [0, 100];
  currentPage.value = 1;
  fetchPositions();
}

const handleSizeChange = (size) => { pageSize.value = size; fetchPositions() }
const handleCurrentChange = (page) => { currentPage.value = page; fetchPositions() }
const viewPositionDetail = (id) => router.push(`/position/detail/${id}`)

const applyPosition = async (position) => {
  if (!userStore.isLoggedIn) {
    ElMessageBox.confirm('登录后即可申请职位', '提示', { type: 'info', confirmButtonText: '去登录' })
      .then(() => router.push({ path: '/login', query: { redirect: route.fullPath } }))
    return
  }
  if (!userStore.isStudent) { return ElMessage.warning('仅限学生用户申请') }
  const hasStudentProfile = await ensureStudentProfile(request, router, route.fullPath)
  if (!hasStudentProfile) {
    return
  }

  selectedPosition.value = position
  applyForm.positionId = position.id
  applyForm.resumeId = resumeList.value[0]?.id || ''
  applyDialogVisible.value = true
}

const submitApplication = () => {
  request.post('/application', applyForm, {
    successMsg: '投递成功',
    onSuccess: () => { applyDialogVisible.value = false; router.push('/application') }
  })
}

const goToCreateResume = () => { applyDialogVisible.value = false; router.push('/resume/edit/new') }

const formatSalaryDisplay = (min, max) => {
  if (!min && !max) return '薪资面议'
  const minK = min ? (min / 1000).toFixed(0) : '0'
  const maxK = max ? (max / 1000).toFixed(0) : '不限'
  return `${minK}K - ${maxK}K`
}

onMounted(() => { fetchPositions(); fetchUserResumes() })
</script>

<style lang="scss" scoped>
@use "sass:map";
@use '@/styles/theme.scss' as *;

.position-list-page {
  max-width: 1400px;
  margin: 0 auto;
  padding-bottom: 6rem;
}

// Hero Search Section
.search-hero {
  padding: 4rem 2rem 2rem;
  text-align: center;
  
  .hero-title { font-size: 3rem; font-weight: 800; @include aurora-text; margin-bottom: 1rem; }
  .hero-subtitle { font-size: 1.2rem; color: map.get($theme, text-light); margin-bottom: 3.5rem; }
}

.mega-search-container {
  max-width: 900px;
  margin: 0 auto;
  
  .search-input-wrapper {
    display: flex;
    align-items: center;
    padding: 8px 10px 8px 24px;
    height: 72px;
    background: white;
    border-radius: 36px;
    box-shadow: 0 15px 45px rgba(0,0,0,0.06);
    border: 1px solid rgba(0,0,0,0.02);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    
    &:focus-within {
      transform: translateY(-2px);
      box-shadow: 0 20px 55px rgba(99, 102, 241, 0.1);
      border-color: rgba(99, 102, 241, 0.2);
    }
    
    .search-icon { font-size: 1.6rem; color: map.get($theme, primary); margin-right: 16px; }
    
    input {
      flex: 1;
      border: none;
      outline: none;
      font-size: 1.25rem;
      font-weight: 500;
      color: map.get($theme, text-main);
      &::placeholder { color: #9ca3af; }
    }
    
    .mega-search-btn {
      height: 56px;
      padding: 0 36px;
      border-radius: 28px;
      background: linear-gradient(135deg, map.get($theme, primary), map.get($theme, accent));
      color: white;
      border: none;
      font-size: 1.15rem;
      font-weight: 800;
      cursor: pointer;
      transition: all 0.3s;
      &:hover { filter: brightness(1.1); transform: scale(1.02); }
    }
  }
}

// Filter Hub
.filter-hub-container {
  max-width: 1100px;
  margin: 0 auto 4rem;
  padding: 0 2rem;
}

.filter-hub {
  padding: 2.5rem;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 24px;
  
  .filter-row {
    display: flex;
    flex-wrap: wrap;
    gap: 3rem;
    align-items: center;
  }
  
  .filter-item {
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
    
    .filter-label { font-size: 0.95rem; font-weight: 800; color: map.get($theme, text-main); padding-left: 2px; }
    
    .aurora-select, .aurora-input {
      width: 180px;
      :deep(.el-input__wrapper) {
        border-radius: 12px;
        height: 44px;
        background: white;
        border: 1px solid rgba(0,0,0,0.05);
      }
    }
  }
  
  .salary-filter {
    flex: 1;
    min-width: 300px;
    
    .salary-slider-wrapper {
      padding: 0 10px;
      .salary-text-range { margin-top: 0.5rem; font-size: 0.9rem; font-weight: 700; color: map.get($theme, primary); text-align: center; }
    }
  }
  
  .filter-actions {
    .reset-btn { font-weight: 700; color: map.get($theme, text-light); &:hover { color: map.get($theme, primary); } }
  }
}

// Results
.results-layout {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2.5rem;
  
  .results-count { color: map.get($theme, text-light); font-size: 1.1rem; strong { @include aurora-text; font-size: 1.4rem; font-weight: 800; margin: 0 4px; } }
  
  .sort-options {
    display: flex;
    gap: 2rem;
    span { 
      font-size: 1rem; font-weight: 600; color: map.get($theme, text-light); cursor: pointer; transition: 0.3s;
      &.active { color: map.get($theme, primary); position: relative; &::after { content: ''; position: absolute; bottom: -6px; left: 0; right: 0; height: 3px; background: map.get($theme, primary); border-radius: 2px; } }
    }
  }
}

.positions-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2.5rem;
}

.position-card-modern {
  @include glass-card;
  padding: 0;
  border-radius: 28px;
  background: white;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  
  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 25px 50px rgba(0,0,0,0.08);
    .pos-title { color: map.get($theme, primary); }
  }
  
  .card-inner { padding: 2.2rem; }
  
  .card-header {
    margin-bottom: 1.8rem;
    .pos-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; }
    .pos-title { font-size: 1.5rem; font-weight: 800; color: map.get($theme, text-main); margin: 0; flex: 1; transition: 0.3s; }
    .pos-salary { font-size: 1.3rem; font-weight: 900; color: map.get($theme, primary); margin-left: 1rem; }
    
    .company-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      .company-name { font-size: 1.1rem; font-weight: 700; color: map.get($theme, text-light); }
      .company-logo :deep(.el-avatar) { border-radius: 14px; background: #f9fafb; border: 1px solid #f3f4f6; }
    }
  }
  
  .pos-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    margin-bottom: 1.8rem;
    .meta-pill {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.9rem;
      font-weight: 600;
      color: map.get($theme, text-light);
      background: #f9fafb;
      padding: 6px 14px;
      border-radius: 100px;
      .el-icon { color: map.get($theme, primary); }
    }
  }
  
  .pos-tags {
    display: flex;
    gap: 0.8rem;
    margin-bottom: 2rem;
    .tag { font-size: 0.85rem; font-weight: 800; padding: 4px 12px; border-radius: 8px; }
    .type-tag { background: rgba(99, 102, 241, 0.1); color: map.get($theme, primary); }
    .cat-tag { background: rgba(16, 185, 129, 0.1); color: #059669; }
  }
  
  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 1.5rem;
    border-top: 1px solid #f3f4f6;
    .publish-date { font-size: 0.85rem; color: #9ca3af; font-weight: 500; }
    .quick-apply-btn { border-radius: 12px; font-weight: 800; padding: 0 1.5rem; height: 40px; }
  }
}

.pagination-container { margin-top: 5rem; display: flex; justify-content: center; }

// Responsive
@media (max-width: 1200px) { .positions-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 900px) { .filter-row { gap: 1.5rem; } .aurora-select, .aurora-input { width: 100% !important; } }
@media (max-width: 768px) { .positions-grid { grid-template-columns: 1fr; } .hero-title { font-size: 2.2rem; } .mega-search-btn span { display: none; } .mega-search-btn { padding: 0 20px !important; } }
</style> 
