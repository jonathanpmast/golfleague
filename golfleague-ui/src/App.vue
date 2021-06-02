<template>  
  <div class="grid md:grid-cols-3">
    <div class="md:col-span-1 md:flex md:justify-end">
      <the-nav />
    </div>

    <main class="px-16 py-6 md:col-span-2 bg-gray-100">
      <div class="flex justify-center md:justify-end">
        <!-- <a href="#">Log in</a>
        <a href="#">Sign up</a> -->
      </div>

      <header>
        <h2 class="text-gray-700 text-4xl font-bold">
          Business Men's Golf League
        </h2>
        <h3 class="text-2xl font-light">at Boone Links Golf Course</h3>
      </header>
      
      <router-view />
      
    </main>
  </div>
</template>

<script>
import TheNav from './components/Nav.vue'

export default {
    components:{TheNav}    
}
</script>

<style>
</style>