___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "IP truncator",
  "description": "This variable template allows you to truncate an IP address at the needed byte.\n- 1.2.3.4\n- 1.2.3.0\n- 1.2.0.0\n- 1.0.0.0",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "truncate_rule",
    "displayName": "Which ip_address format to return ?",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "4_bytes",
        "displayValue": "1.2.3.4 (Full ip - Not truncated)"
      },
      {
        "value": "3_bytes",
        "displayValue": "1.2.3.0 (Last byte anonymized)"
      },
      {
        "value": "2_bytes",
        "displayValue": "1.2.0.0 (Last 2 bytes anonymized)"
      },
      {
        "value": "1_bytes",
        "displayValue": "1.0.0.0 (Last 3 bytes anonymized)"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "ip_address",
    "displayName": "1.2.3.4",
    "simpleValueType": true,
    "canBeEmptyString": false,
    "help": "default IP if empty : ip_override"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require("logToConsole");
const getAllEventData = require("getAllEventData");

// Retrieve event data and select the IP address (custom or fallback)
const eventData = getAllEventData();
const ip = data.ip_address || eventData.ip_override;
const truncateRule = data.truncate_rule;

logToConsole("IP Address: " + ip);
logToConsole("Truncate Rule: " + truncateRule);

if (!ip) {
  logToConsole("No IP address provided.");
  return "Invalid IP Address";
}

// Split the IP into its 4 parts
const ipParts = ip.split(".");
if (ipParts.length !== 4) {
  logToConsole("Invalid IP format: " + ip);
  return "Invalid IP Address";
}

// Define a simple mapping for truncation rules.
// The number represents how many octets to keep.
const rules = {
  "4_bytes": 4,
  "3_bytes": 3,
  "2_bytes": 2,
  "1_bytes": 1
};

const keepCount = rules[truncateRule];
if (!keepCount) {
  logToConsole("Invalid Truncate Rule: " + truncateRule);
  return "Invalid Rule";
}

// For the octets that should be truncated, replace them with "0"
for (let i = keepCount; i < 4; i++) {
  ipParts[i] = "0";
}

const truncatedIP = ipParts.join(".");
logToConsole("Truncated IP Address: " + truncatedIP);
return truncatedIP;


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Full IP
  code: |
    const mockData = {
      ip_address: "192.168.1.1",
      truncate_rule: "4_bytes"
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("192.168.1.1");
- name: Last byte removed
  code: |
    const mockData = {
      ip_address: "192.168.1.1",
      truncate_rule: "3_bytes"
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("192.168.1.0");
- name: Last 2 bytes removed
  code: |
    const mockData = {
      ip_address: "192.168.1.1",
      truncate_rule: "2_bytes"
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("192.168.0.0");
- name: Last 3 bytes removed
  code: |
    const mockData = {
      ip_address: "192.168.1.1",
      truncate_rule: "1_bytes"
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("192.0.0.0");
- name: Invalid IP Address
  code: |-
    const mockData = {
      // Mocked field values
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);


___NOTES___

Created on 19/02/2025 19:23:32


