import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default ({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  
  let _server = {};
  if(mode=='development') {
    _server.port = parseInt(env.VITE_SERVER_PORT) || 3123;
    _server.strictPort = false; // Allow auto-increment if port is busy
  }
  console.log('Vite server config:', _server);
  return defineConfig(
  {
    plugins: [vue()],
    server: _server
  });
}
