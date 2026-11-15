import { ElMessageBox } from 'element-plus'

const MISSING_STUDENT_PROFILE_MESSAGES = [
  '请先完善学生信息',
  '学生信息不存在',
  '未找到该用户的学生信息'
]

let prompting = false

export function isMissingStudentProfileError(error) {
  const message = error?.message || error?.msg || ''
  return MISSING_STUDENT_PROFILE_MESSAGES.some(item => message.includes(item))
}

export async function promptCompleteStudentProfile(router, redirect = '') {
  if (prompting || router.currentRoute.value.path === '/student/profile') {
    return false
  }

  prompting = true

  try {
    await ElMessageBox.confirm(
      '您还未完善学生信息，完善后才能创建简历或申请职位，是否现在前往？',
      '提示',
      {
        confirmButtonText: '去完善',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const query = redirect ? { redirect } : undefined
    await router.push({ path: '/student/profile', query })
    return true
  } catch (_) {
    return false
  } finally {
    prompting = false
  }
}

export async function ensureStudentProfile(request, router, redirect = '') {
  try {
    await request.get('/student/current', null, {
      showDefaultMsg: false
    })
    return true
  } catch (error) {
    if (isMissingStudentProfileError(error)) {
      await promptCompleteStudentProfile(router, redirect)
    }
    return false
  }
}
