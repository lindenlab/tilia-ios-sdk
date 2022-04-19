/**
 * A script that gets used within the build-and-test-app Github Action to upload a file to TestProject, and run integration tests there.
 * One major thing to note is that this just triggers tests to be run, but does not wait for the test to finish successfully.
 * For now, we'll set up Slack alerts from TestProject to let us know if tests passed/failed.
 * This script is based on this TestProject article: https://blog.testproject.io/2019/08/27/test-automation-ci-testproject-api/
*/

require("es6-promise").polyfill();
require("isomorphic-fetch");
const fs = require("fs");

const path = process.argv[6];
const fileSize = fs.statSync(path).size;
let readStream = fs.createReadStream(path);

let newURL = "";
const appId = process.argv[2];
const projectId = process.argv[3];
const apiKey = process.argv[4];
const apiUrl = "https://api.testproject.io/";

const uploadUrlData = {
  headers: {
    Authorization: apiKey,
  },
  method: "GET",
};
const uploadFileData = {
  headers: {
    "cache-control": "no-cache",
    "Content-length": fileSize,
  },
  method: "PUT",
  body: readStream,
};

// Get an upload URL for an application
console.log('about to get upload link...');
fetch(
  apiUrl + `v2/projects/${projectId}/applications/${appId}/file/upload-link`,
  uploadUrlData
)
  .then((result) => {
    return result.json();
  })
  .then((data) => {
    newURL = data.url;
    uploadFile();
  })
  .catch((error) => {
    console.log(error);
  });

// Upload the new file to AWS S3
async function uploadFile() {
  console.log('about to get uploadFile...');
  fetch(newURL, uploadFileData)
    .then((result) => {
      confirmNewFile();
    })
    .catch((error) => {
      console.log(error);
    });
}

// Confirm the new file upload
async function confirmNewFile() {
  console.log('about to get confirmNewFile...');
  const newFileName = process.argv[5];
  const data = {
    headers: {
      accept: "application/json",
      Authorization: apiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      fileName: newFileName,
    }),
    method: "POST",
  };

  fetch(apiUrl + `v2/projects/${projectId}/applications/${appId}/file`, data)
    .then((result) => {
      runJob();
    })
    .catch((error) => {
      console.log(error);
    });
}

// Runs a job in TestProject
async function runJob() {
  console.log('about to get runJob...');
  const jobId = process.argv[7];

  const data = {
    headers: {
      accept: "application/json",
      Authorization: apiKey,
      "Content-Type": "application/json",
    },
    method: "POST",
  };

  fetch(apiUrl + `v2/projects/${projectId}/jobs/${jobId}/run`, data)
    .then((result) => {
      console.log("The CI process completed successfully!");
    })
    .catch((error) => {
      console.log(error);
    });
}
