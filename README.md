<p align="center">
  <a href="https://github.com/autifyhq/actions-mobile-test-run"><img alt="actions-mobile-test-run status" src="https://github.com/autifyhq/actions-mobile-test-run/workflows/test/badge.svg"></a>
</p>

# Run test on Autify for Mobile
Run a test plan on Autify for Mobile.

See our official documentation to get started: https://help.autify.com/mobile/docs/github-actions-integration

## Usage

### Run a test plan with a build ID
```yaml
- uses: autifyhq/actions-mobile-test-run@v1
  with:
    access-token: ${{ secrets.AUTIFY_MOBILE_ACCESS_TOKEN }}
    autify-test-url: https://mobile-app.autify.com/projects/<ID>/test_plans/<ID>
    build-id: AAA
```

This will succeed immediately once the test is started but won't wait the finish of the test.

### Run and wait a test plan with a build ID
```yaml
- uses: autifyhq/actions-mobile-test-run@v1
  with:
    access-token: ${{ secrets.AUTIFY_MOBILE_ACCESS_TOKEN }}
    autify-test-url: https://mobile-app.autify.com/projects/<ID>/test_plans/<ID>
    build-id: AAA
    wait: true
    timeout: 300
```

This will keep running the action until the test finishes or times out.

**Note: This will consume your GitHub Actions hosted runner's minutes. Be careful when extending the timeout value.**

### Run a test plan with a build file
```yaml
- uses: autifyhq/actions-mobile-test-run@v1
  with:
    access-token: ${{ secrets.AUTIFY_MOBILE_ACCESS_TOKEN }}
    autify-test-url: https://mobile-app.autify.com/projects/<ID>/test_plans/<ID>
    build-path: /path/to/my.[app|apk]
```

This will upload the build file first, then start the test plan with the new build ID.

## Options
```yaml
  access-token:
    required: true
    description: 'Access token of Autify for Mobile.'
  autify-test-url:
    required: true
    description: 'URL of a test plan e.g. https://moible-app.autify.com/projects/<ID>/test_plans/<ID>'
  build-id:
    required: false
    description: 'ID of the already uploaded build. (Note: Either build-id or build-path is required but not both)'
  build-path:
    required: false
    description: 'File path to the iOS app (*.app) or Android app (*.apk). (Note: Either build-id or build-path is required but not both)'
  wait:
    required: false
    default: 'false'
    description: 'When true, the action waits until the test finishes.'
  timeout:
    required: false
    description: 'Timeout seconds when waiting.'
  autify-path:
    required: false
    default: 'autify'
    description: 'A path to `autify`. If set, this action will not install autify-cli.'
```

## Outputs
```yaml
  exit-code:
    description: 'Exit code of autify-cli. 0 means succeeded.'
  log:
    description: 'Log of stdout and stderr.'
  build-id:
    description: 'Returned build id on the workspace.'
  result-url:
    description: 'Test result URL on Autify for Mobile'
```
