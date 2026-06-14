<template>
  <div class="nf">
    <van-empty image="error" description="页面不存在">
      <van-button round type="primary" color="#ff6b35" @click="$router.replace('/login')">
        返回首页
      </van-button>
    </van-empty>
  </div>
</template>

<script>
export default { name: 'NotFound' }
</script>

<style scoped>
.nf {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
