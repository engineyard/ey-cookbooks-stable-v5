Feature: HAProxy
  Proxy/load balancer service

  Scenario: Unecessary restarts on a redeploy
    Given the epsilon scenario
    Then haproxy is not restarted on a redeploy
