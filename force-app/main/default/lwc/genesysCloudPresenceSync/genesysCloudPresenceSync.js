import { LightningElement } from "lwc";
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import syncGenesysCloudPresences from "@salesforce/apex/GenesysCloudPresenceSyncService.syncGenesysCloudPresences";
import deleteAllGenesysCloudPresences from "@salesforce/apex/GenesysCloudPresenceSyncService.deleteAllGenesysCloudPresences";
import reloadGenesysToSalesforcePresenceMapping from "@salesforce/apex/GenesysCloudPresenceSyncService.reloadGenesysToSalesforcePresenceMapping";
import deleteAllGenesysToSalesforcePresenceMapping from "@salesforce/apex/GenesysCloudPresenceSyncService.deleteAllGenesysToSalesforcePresenceMapping";

import syncServiceCloudPresences from "@salesforce/apex/ServiceCloudPresenceSyncService.syncServiceCloudPresences";
import deleteAllServiceCloudPresences from "@salesforce/apex/ServiceCloudPresenceSyncService.deleteAllServiceCloudPresences";
import reloadSalesforceToGenesysPresenceMapping from "@salesforce/apex/ServiceCloudPresenceSyncService.reloadSalesforceToGenesysPresenceMapping";
import deleteAllSalesforceToGenesysPresenceMapping from "@salesforce/apex/ServiceCloudPresenceSyncService.deleteAllSalesforceToGenesysPresenceMapping";

export default class CXCloudPresenceMapping extends LightningElement {
  progress = 0;
  isProgressing = false;
  isSimpleView = true;

  async syncGenesysPresenceHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const result = await syncGenesysCloudPresences();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
        } else {
          this.showToast(
            "error",
            "Operation Failed",
            "The result format was not as expected."
          );
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }
  async deleteAllGenesysPresenceHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const count = await deleteAllGenesysCloudPresences();
        let message =
          count === 0
            ? "No records were removed"
            : `${count} records were successfully removed`;
        this.showToast("success", "Operation Successful", message);
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async sycnSalesforcePresenceHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const result = await syncServiceCloudPresences();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
        } else {
          this.showToast(
            "error",
            "Operation Failed",
            "The result format was not as expected."
          );
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }
  async deleteAllSalesforcePresenceHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const count = await deleteAllServiceCloudPresences();
        let message =
          count === 0
            ? "No records were removed"
            : `${count} records were successfully removed`;
        this.showToast("success", "Operation Successful", message);
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async reloadGenesysToSalesforcePresenceMappingHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const result = await reloadGenesysToSalesforcePresenceMapping();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
        } else {
          this.showToast(
            "error",
            "Operation Failed",
            "The result format was not as expected."
          );
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }
  async deleteAllGenesysToSalesforcePresenceMappingHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const count = await deleteAllGenesysToSalesforcePresenceMapping();
        let message =
          count === 0
            ? "No records were removed"
            : `${count} records were successfully removed`;
        this.showToast("success", "Operation Successful", message);
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async reloadSalesforceToGenesysPresenceMappingHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const result = await reloadSalesforceToGenesysPresenceMapping();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
        } else {
          this.showToast(
            "error",
            "Operation Failed",
            "The result format was not as expected."
          );
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async deleteAllSalesforceToGenesysPresenceMappingHandler() {
    try {
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        const count = await deleteAllSalesforceToGenesysPresenceMapping();
        let message =
          count === 0
            ? "No records were removed"
            : `${count} records were successfully removed`;
        this.showToast("success", "Operation Successful", message);
      }
    } catch (error) {
      this.handleError(error);
    }
  }
  async syncPresenceHandler() {
    try {
      this.progress = 0;
      this.isProgressing = true;
      const confirm = await this.confirmAction();
      if (confirm) {
        // Await the result of the Apex method
        let result = await syncGenesysCloudPresences();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
          this.progress = 25;
        } else {
          this.handleError(new Error("The result format was not as expected."));
        }
        result = await syncServiceCloudPresences();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
          this.progress = 50;
        } else {
          this.handleError(new Error("The result format was not as expected."));
        }
        result = await reloadSalesforceToGenesysPresenceMapping();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
          this.progress = 75;
        } else {
          this.handleError(new Error("The result format was not as expected."));
        }
        result = await reloadGenesysToSalesforcePresenceMapping();
        if (Array.isArray(result)) {
          this.showToast(
            "success",
            "Operation Successful",
            "Task completed successfully!"
          );
          this.progress = 100;
        } else {
          this.handleError(new Error("The result format was not as expected."));
        }
      }
      this.isProgressing = false;
    } catch (error) {
      this.handleError(error);
      this.isProgressing = false;
    }
  }

  get showProgressBar() {
    return this.progress !== 0 && this.isProgressing;
  }
  handleError(error) {
    // Default error message
    let msg = "An unexpected error occurred.";
    // Check if the error is an instance of an error and has a message
    if (error instanceof Error && error.message) {
      msg = error.message;
    }
    // Check if error has a body with a message
    else if (error?.body?.message) {
      msg = error.body.message;
    }
    // Show the toast with the error message
    this.showToast("error", "Operation Failed", msg);
  }

  async confirmAction() {
    return LightningConfirm.open({
      message: "Are you sure you want to proceed?",
      variant: "header", // Optional, hides the default header
      label: "Confirmation", // Title of the confirmation dialog
      theme: "warning"
    });
  }

  showToast(variant, title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }

  switchOptionViewHandler(event) {
    this.isSimpleView = event.target.checked;
  }
}
