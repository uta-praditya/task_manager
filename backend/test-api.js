// Simple API test script
const http = require('http');

const makeRequest = (options, data) => {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
};

async function testAPI() {
  console.log('Testing Task Manager API...\n');
  
  try {
    // Test health check
    const health = await makeRequest({
      hostname: 'localhost',
      port: 3000,
      path: '/api/health',
      method: 'GET'
    });
    console.log('Health Check:', health.data);
    
    // Test register
    const register = await makeRequest({
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/register',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, {
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User'
    });
    console.log('Register:', register.data);
    
    if (register.data.token) {
      // Test create task
      const task = await makeRequest({
        hostname: 'localhost',
        port: 3000,
        path: '/api/tasks',
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${register.data.token}`
        }
      }, {
        title: 'Test Task',
        description: 'This is a test task',
        priority: 2
      });
      console.log('Create Task:', task.data);
      
      // Test get tasks
      const tasks = await makeRequest({
        hostname: 'localhost',
        port: 3000,
        path: '/api/tasks',
        method: 'GET',
        headers: { 
          'Authorization': `Bearer ${register.data.token}`
        }
      });
      console.log('Get Tasks:', tasks.data);
    }
    
  } catch (error) {
    console.error('Test failed:', error.message);
  }
}

// Run test if server is running
setTimeout(testAPI, 1000);