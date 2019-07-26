if (typeof (SYED) === "undefined") {
    SYED = { __namespace: true };
}
if (typeof (SYED.SolutionDetail) === "undefined") {
    SYED.SolutionDetail = { __namespace: true };
}

'use strict';
SYED.SolutionDetail.EventHandler =
    {
        OnRowSelected: function (executionContext) {
            try {
                executionContext.getFormContext().getData().getEntity().attributes.forEach(function (attr) {
                    if (attr.getName() !== "syed_order" && attr.getName() !== "syed_newversion") {
                        attr.controls.forEach(function (c) {
                            c.setDisabled(true);
                        })
                    }
                });
            }
            catch (ex) {
                console.log("Error at SYED.SolutionDetail.EventHandler.OnRowSelected function: " + ex.message + "|" + "Stack: " + ex.stack);
                throw ex;
            }
        },

        Execute: function (executionContext) {
            try {
                var formContext = executionContext.getFormContext();
                var formType = formContext.ui.getFormType();

                if (formType == "1") {
                    formContext.ui.tabs.get("MergeSolution").setVisible(false);
                }
                else {
                    formContext.ui.tabs.get("MergeSolution").setVisible(true);
                }
            }
            catch (ex) {
                console.log("Error at SYED.SolutionDetail.EventHandler.Execute function: " + ex.message + "|" + "Stack: " + ex.stack);
                throw ex;
            }
        },

        SetSourcecontrolValues: function (executionContext) {
            try {
                var formContext = executionContext.getFormContext();
                var sourceControlValues = formContext.getAttribute("syed_crmsolutionsid").getValue();
                if (sourceControlValues != null || sourceControlValues != undefined) {
                    sourceControlValues = sourceControlValues[0].id.replace("{", "").replace("}", "").toUpperCase();

                    Xrm.WebApi.online.retrieveRecord("syed_mastersolutions", sourceControlValues, "?$select=syed_friendlyname,syed_installedon,syed_ismanaged,syed_listofsolutions,syed_mastersolutionsid,syed_name,syed_order,syed_publisher,syed_solutionid,syed_solutioninstalledon,syed_version,syed_versionnumber").then(
                        function success(result) {
                            formContext.getAttribute("syed_friendlyname").setValue(result["syed_friendlyname"]);
                            formContext.getAttribute("syed_ismanaged").setValue(result["syed_ismanaged"]);
                            formContext.getAttribute("syed_name").setValue(result["syed_name"]);
                            formContext.getAttribute("syed_publisher").setValue(result["syed_publisher"]);
                            formContext.getAttribute("syed_solutioninstalledon").setValue(new Date(result["syed_solutioninstalledon"]));
                            formContext.getAttribute("syed_listofsolutions").setValue(result["syed_listofsolutions"]);
                            formContext.getAttribute("syed_version").setValue(result["syed_version"]);
                            formContext.getAttribute("syed_solutionid").setValue(result["syed_solutionid"]);
                            formContext.getAttribute("syed_name").setValue("SOL-" + new Date().toLocaleString());
                            formContext.getAttribute("syed_order").setValue(0);

                        },
                        function (error) {
                            Xrm.Utility.alertDialog(error.message);
                        }
                    );
                }
                else {
                    if (!Xrm.Internal.isUci()) {
                        formContext.getAttribute("syed_friendlyname").setValue("");
                        formContext.getAttribute("syed_ismanaged").setValue("");
                        formContext.getAttribute("syed_name").setValue("");
                        formContext.getAttribute("syed_publisher").setValue("");
                        formContext.getAttribute("syed_solutioninstalledon").setValue("");
                        formContext.getAttribute("syed_listofsolutions").setValue("");
                        formContext.getAttribute("syed_version").setValue("");
                        formContext.getAttribute("syed_solutionid").setValue("");
                        formContext.getAttribute("syed_order").setValue(0);
                    }
                }
            }
            catch (ex) {
                console.log("Error at SYED.SolutionDetail.EventHandler.SetSourcecontrolValues function: " + ex.message + "|" + "Stack: " + ex.stack);
                throw ex;
            }
        }
    }