<template>
  <nav class="text-right">
    <div class="flex justify-between items-center">
      <h1 class="font-bold uppercase p-4 border-b border-gray-100">
        <a href="/">B M G N K Y</a>
      </h1>
      <div
        id="burger"
        class="px-4 cursor-pointer md:hidden"
        @click.prevent="toggleMenu"
      >
        <svg
          class="w-6 h-6"
          fill="none"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          stroke="currentColor"
          viewBox="0 0 24 24"
        ><path d="M4 6h16M4 12h16M4 18h16" /></svg>
      </div>
    </div>
    <ul
      class="text-sm mt-6 md:block"
      :class="{hidden : menuIsHidden}"
    >
      <li
        v-for="item in navData"
        :key="item.id"
        class="text-gray-700 font-bold py-1"
      >
        <router-link
          :to="item.link"
          class="flex justify-end px-4"
        >
          <span>{{ item.title }}</span>
          <svg
            class="w-5 ml-1"
            fill="none"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            stroke="currentColor"
            viewBox="0 0 24 24"
          ><path :d="item.iconPath" /></svg>
        </router-link>
      </li>
    </ul>
  </nav>
</template>

<script>
import data from "../common/data";
import { ref } from "vue";
export default {
  
  setup() {
      const navData = data.navData;
      const menuIsHidden = ref(true);

      const toggleMenu = () => { 
          menuIsHidden.value = !menuIsHidden.value;
        };
      return {
          navData,
          menuIsHidden,
          toggleMenu
      }
  }
}


</script>
