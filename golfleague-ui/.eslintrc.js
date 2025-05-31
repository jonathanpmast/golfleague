module.exports = {
    env: {
        node: true,
        es2022: true,
        browser: true
    },
    parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module'
    },
    extends: [
        // add more generic rulesets here, such as:
        "eslint:recommended",
        "plugin:vue/vue3-recommended",
        // "prettier",
        // "prettier/vue",
    ],
    rules: {
        // override/add rules settings here, such as:
        // 'vue/no-unused-vars': 'error'
    }
}