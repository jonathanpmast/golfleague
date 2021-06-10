<template>
    <span class="hidden sm:inline">{{ name }}</span>
    <span class="sm:hidden">{{ shortName }}</span>
</template>
<script>
export default {
    props: {
        name: {
            type: String,
            default() {
                return "Full Name";
            }
        },
        shortName: {
            type: String,
            default() {
                return "F Name"
            }
        }
        
    },
    setup() {

    }
}
</script>