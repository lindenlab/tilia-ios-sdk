var axios = require("axios");
const fs = require("fs");

const myArgs = process.argv.slice(2); // expecting an command line arg for path to ipa file: `$ node thisfile.js PATH_TO_IPA_FILE

const TEST_PROJECT_PROJECT_ID = "pML79r6fo0maool6VQjffw";
const TEST_PROJECT_APP_ID = "j2_PA4blFk24KXXWnb0GWA";

const PATH_TO_IPA_FILE = myArgs[0] || null;
console.log('PATH_TO_IPA_FILE:', PATH_TO_IPA_FILE);
const API_KEY = process.env.TEST_PROJECT_API_KEY;

const getUploadLink = () => {
  console.log("in getUploadLink");
  const url = `https://api.testproject.io/v2/projects/${TEST_PROJECT_PROJECT_ID}/applications/${TEST_PROJECT_APP_ID}/file/upload-link`;
  return axios.get(url, {
    headers: {
      "Content-Type": "application/json",
      Authorization: API_KEY,
    },
  });
};

const uploadFile = (uploadUrl) => {
  console.log("in uploadFile");
  var data = fs.readFileSync(PATH_TO_IPA_FILE);

  var config = {
    method: "PUT",
    url: uploadUrl,
    headers: {
      "Content-Type": "application/octet-stream",
    },
    data: data,
  };

  return new Promise((resolve, reject) => {
    axios(config)
      .then((response) => {
        if (response.status === 200) {
          resolve(response.status);
        } else {
          reject(
            new Error("Received a non 200 status code when uploading ipa file")
          );
        }
      })
      .catch((err) => reject(err));
  });
};

const verifyUpload = () => {
  console.log("in verifyUpload");
  const url = `https://api.testproject.io/v2/projects/${TEST_PROJECT_PROJECT_ID}/applications/${TEST_PROJECT_APP_ID}/file`;
  return new Promise((resolve, reject) => {
    axios
      .post(
        url,
        {
          fileName: "TiliaSDK.ipa",
        },
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: "NR1-99BPYPuEh4mYDPMy7r0unqJjDYpoyPrLj4EaT-01",
          },
        }
      )
      .then((response) => {
        const { status } = response;
        if (response.status === 200) {
          resolve(response.status);
        } else {
          reject(
            new Error(
              "Received a non 200 status code when trying to verify file upload"
            )
          );
        }
      })
      .catch((err) => reject(err));
  });
};

const runUploadToTestProject = async () => {
  const { data: getUploadLinkData } = await getUploadLink();
  const { url } = getUploadLinkData;
  const uploadStatus = await uploadFile(url);
  const verifyUploadStatus = await verifyUpload();
};

runUploadToTestProject();
