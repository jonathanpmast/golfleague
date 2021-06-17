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
      <li v-if="userInfo" class="text-gray-700 font-bold pl-5 text-left flex justify-end px-4">        
          <span>Hi {{userInfo.idTokenClaims.given_name}}!</span>
          <svg class="w-5 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
      </li>
    
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
      <li class="border-b mr-4 my-2 border-gray-100" />
      <li 
        v-if="!isAuthenticated()"
        class="text-gray-700 font-bold py-1">
        <div class="flex justify-end px-4">
          <button
            class="font-bold"
            @click="signIn()"
          >
            Sign In
          </button>
          <svg class="w-5 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path></svg>
        </div>
      </li>
      <li 
        v-if="isAuthenticated()"
        class="text-gray-700 font-bold py-1">
        <div class="flex justify-end px-4">
          <button          
              class="font-bold"
              @click="signOut()"
          >
              Sign Out
          </button>
          <svg class="w-5 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
        </div>
      </li>
    </ul>
  </nav>
</template>

<script>
import data from "../common/data";
import { ref, inject} from "vue";
export default {
  
  setup() {
      const navData = data.navData;
      const menuIsHidden = ref(true);
      const userInfo = inject('userInfo');
      const msalPlugin = inject('msalPluginInstance');
      const toggleMenu = () => { 
          menuIsHidden.value = !menuIsHidden.value;
        };
      const isAuthenticated = () => {
        return msalPlugin.getIsAuthenticated();
      }

      const signIn = async () => {
        await msalPlugin.signIn();
      }

      const signOut = async() => {
        await msalPlugin.signOut();
      }
      return {
          navData,
          menuIsHidden,
          toggleMenu,
          userInfo,
          isAuthenticated,
          signIn,
          signOut
      }
  }
}


</script>
