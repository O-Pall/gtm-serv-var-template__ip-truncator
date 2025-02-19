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
const makeNumber = require("makeNumber");
const getAllEventData = require("getAllEventData");

const eventData = getAllEventData(); // Retrieve event data
const ip = data.ip_address; // Fallback to IP address
const truncateRule = data.truncate_rule; // Selected truncation rule

// Debugging
logToConsole("IP Address: " + ip);
logToConsole("Truncate Rule: " + truncateRule);

if (!ip) {
  logToConsole("No IP address provided.");
  return "Invalid IP Address"; // Return a string, not a boolean
}

// Split the IP into parts
const ipParts = ip.split(".");
if (ipParts.length !== 4) {
  logToConsole("Invalid IP format: " + ip);
  return "Invalid IP Address"; // Return string if IP format is incorrect
}

// Validate that all parts are numeric
if (ipParts.some(part => makeNumber(part) === null)) {
  logToConsole("Non-numeric IP parts found: " + ip);
  return "Invalid IP Address";
}

// Apply truncation based on the selected rule
let truncatedIP;
switch (truncateRule) {
  case "4_bytes":
    truncatedIP = ip; // No truncation
    break;
  case "3_bytes":
    ipParts[3] = "0";
    truncatedIP = ipParts.join(".");
    break;
  case "2_bytes":
    ipParts[2] = "0";
    ipParts[3] = "0";
    truncatedIP = ipParts.join(".");
    break;
  case "1_bytes":
    ipParts[1] = "0";
    ipParts[2] = "0";
    ipParts[3] = "0";
    truncatedIP = ipParts.join(".");
    break;
  default:
    logToConsole("Invalid Truncate Rule: " + truncateRule);
    return "Invalid Rule";
}

// Debug final output
logToConsole("Truncated IP Address: " + truncatedIP);

// Return the final truncated IP
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

Created on 19/02/2025 15:30:20


