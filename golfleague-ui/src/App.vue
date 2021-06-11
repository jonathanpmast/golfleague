<template>  
  <div class="grid md:grid-cols-5 lg:grid-cols-7">
    <div class="md:col-span-1 md:flex md:justify-end">
      <the-nav />
    </div>

    <main class="px-1 sm:px-4 md:px-16 sm:mr-8 py-6 md:col-span-4 lg:col-span-6 bg-gray-100">
      <div class="flex justify-center md:justify-end">
        <!-- <a href="#">Log in</a>
        <a href="#">Sign up</a> -->
      </div>

      <header class="sm:ml-0 ml-2">
        <h2 class="text-gray-700 text-xl md:text-2xl font-bold">
          Business Men's Golf League
        </h2>
        <h3 class="text-sm font-light">
          at Boone Links Golf Course
        </h3>
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