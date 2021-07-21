# azurerm-iot-route-sample

This repository contains samples for the `azurerm` [Bug 12439]( https://github.com/terraform-providers/terraform-provider-azurerm/issues/12439)

## Samples

### `tf-sample`

In this sample the iot hub is created using the `azurerm_iothub` resource and later on a route is added with the `azurerm_iothub_route`.
This will cause an issue. After deploying the infratructur initialy and the running `terraform apply` again, the route created using the  `azurerm_iothub_route` is deleted.

### `tf-sample-alternative-iot-route-1`

In this sample the iot hub and the routes are created using the `azurerm_iothub` resource. Unlike the `tf-sample` this will not cause any overwrite issues.

### `tf-sample-alternative-iot-route-2`

In this sample the iot hub and the routes are created using the `azurerm_iothub_route` resource. Unlike the `tf-sample` this will not cause any overwrite issues.

