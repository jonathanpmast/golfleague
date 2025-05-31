<template>
  <div class="mt-6">
    Built by <a :href="authorData.profileLink">Jonathan Mast</a> to learn a few things about:
    <ul class="list-disc pl-5 py-2">
      <li
        v-for="(item,idx) in links"
        :key="idx"
      >
        <a
          class="underline"
          :href="item.link"
        >{{ item.title }}</a>
      </li> 
    </ul>
    Also it gives me an excuse to think about my golf league when it's cold and/or rainy outside :)
    <p>
      If you're curious, all of the source code is <a
        class="underline"
        href="https://github.com/jonathanpmast/golfleague"
      >available on GitHub</a>
    </p>
  </div>
</template>
<script>
import {ref} from "vue"
export default {
    name: 'AboutPage',
    setup() {
     const authorData = ref({
         authorName: "Jonathan Mast",
         profileLink: "https://github.com/jonathanpmast"
     });
     const links = ref([
        {link: "https://v3.vuejs.org", title: "Vue"},
        {link: "https://tailwindcss.com/",title: "Tailwind CSS"},
        {link: "https://github.com/features/actions", title: "Github Actions"},
        {link: "https://docs.microsoft.com/en-us/azure/static-web-apps/overview", title: "Azure Static Web Apps"},
        {link: "https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview", title:"Azure Functions"},
        {link: "https://docs.microsoft.com/en-us/azure/cosmos-db/introduction", title: "Azure Cosmos Db"}
     ]);
     return {
         authorData,
         links,
     }
    }
}
</script>
