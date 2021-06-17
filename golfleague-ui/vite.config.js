import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default ({ mode }) => {
  process.env = {...process.env, ...loadEnv(mode, process.cwd())};
  
  let _server = {};
  if(mode=='development') {
    _server.port = process.env.VITE_SERVER_PORT || 3000
  }
  console.log(_server);
  return defineConfig(
  {
    plugins: [vue()],
    server: _server
  });
}
