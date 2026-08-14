# Spring Boot 4 Upgrade Summary

Target: **Spring Boot 4.1.0**, Spring Cloud **2025.1.2** ("Oakwood"),
`io.spring.dependency-management` **1.1.7**, Gradle **9.5.1**, Java **17** (unchanged).

Delivered on a `spring-boot-4` branch in both repos; `main` is untouched in each.

- Instructions repo (`course-spring-cloud-stream`): `spring-boot-4` branch, commit `e0c412e`.
- Code repo (`course-spring-cloud-stream-code`): `spring-boot-4` branch, rewritten from
  `lab-format` (the branch every workshop actually checks out — `main` there is an unused
  template lineage and was left alone).

## Actions taken

### Code repo history rewrite

Rewrote all 23 commits on `lab-format` onto `spring-boot-4` with `git filter-repo
--blob-callback`, preserving every commit message byte-for-byte (module tags live there).
Substitutions applied wherever the real course build files matched (gated on the exact
pinned `3.2.5` Boot version, so the dead legacy `cashcard/` template directory — pinned at
3.2.4 — was left untouched):

- Boot `3.2.5` → `4.1.0`, dependency-management `1.1.4` → `1.1.7`, Spring Cloud
  `2023.0.1` → `2025.1.2`, Gradle wrapper `8.7` → `9.5.1`.
- `java { sourceCompatibility = '17' }` → `java { toolchain { languageVersion = ... } }`.
- `org.springframework.kafka:spring-kafka(-test)` → `org.springframework.boot:spring-boot-starter-kafka(-test)`.
- `spring-boot-starter-web` → `spring-boot-starter-webmvc`, with test-scope elevated to `-webmvc-test`.
- `org.testcontainers:kafka` → `org.testcontainers:testcontainers-kafka` + added `testcontainers-junit-jupiter`.
- Added `testRuntimeOnly 'org.junit.platform:junit-platform-launcher'` everywhere (missing before, now required).

### Fixes surfaced by actually building each commit (not assumptions)

- **Jackson**: `spring-boot-starter-kafka` no longer transitively exposes `jackson-databind`
  on the compile classpath. Added it explicitly to source/enricher/sink.
- **`TestRestTemplate`**: moved to `org.springframework.boot.resttestclient`, no longer
  auto-registered under `@SpringBootTest(webEnvironment = RANDOM_PORT)`. Added
  `@AutoConfigureTestRestTemplate` + the new import in the source module's controller test
  and the on-demand e2e test.
- **`@MockBean`**: fully removed in Boot 4 (not just deprecated) → `@MockitoBean`
  (`org.springframework.test.context.bean.override.mockito`), in the enricher and source
  unit tests.
- **Testcontainers 2.0**: `org.testcontainers.containers.KafkaContainer` moved to
  `org.testcontainers.kafka` and now strictly validates image family — the course's
  Confluent image (`confluentinc/cp-kafka`) needs the dedicated `ConfluentKafkaContainer`,
  not the generic one.
- **On-demand e2e test race**: Spring Cloud Stream 5.x dropped the test binder's
  auto-registration (no more `META-INF/spring.binders` / `AutoConfiguration.imports` in
  `spring-cloud-stream-test-binder`). Confirmed via a side-by-side run against the
  original Boot 3.2.5 repo that `CashCardTransactionOnDemandE2ETests` had been silently
  running against the in-memory test binder the whole time — it never exercised real
  Kafka. Under Boot 4 it correctly wires the real Kafka binder, which surfaces a genuine
  race: the single StreamBridge-published message can arrive before the consumer's
  initial partition assignment completes. Fixed by retrying the POST inside the
  Awaitility poll loop instead of publishing exactly once.

### Verification

- Every one of the 10 tagged commits plus the untagged "Extract domain module" commit
  builds and its tests pass under Boot 4.1.0 / JDK 17.
- `e2e-tests-start` still fails with the *same* `IllegalStateException: Found multiple
  @SpringBootConfiguration annotated classes` it always did — confirmed by running the
  unmodified original commit — so this is the course's existing intentional failure
  waypoint, not a regression.
- The Testcontainers-based e2e test (`CashCardTransactionStreamE2EContainerTests`) could
  not be run to a green result in this sandbox — Docker isn't reachable from the Gradle
  test JVM here (`Could not find a valid Docker environment`). The actual compatibility
  bug (image-family validation) is fixed and confirmed: the failure mode changed from
  "image incompatible" to "no Docker daemon", which is an environment limitation, not a
  code issue. Re-run this test in an environment with a JVM-reachable Docker daemon
  before publishing.

### Instructions repo updates

- All 7 `workshops/*/resources/workshop.yaml` files: `ref: lab-format` → `ref: spring-boot-4`.
- Lab content updated to match the new coordinates/APIs above in:
  `01-initializr/01-spring-initializr.md` (version text),
  `02-create-source/02-review.md`, `06-testing-setup.md`, `07-testing-logic.md`,
  `03-swap-middleware/03-use-rabbitmq.md` (+ noted `spring-boot-starter-amqp` is now required
  alongside the RabbitMQ binder, mirroring the Kafka starter requirement),
  `04-stream-bridge/02-review-controller.md`, `04-update-controller.md`,
  `05-processor/08-test-enrich.md`,
  `07-e2e-tests/02-test-support.md`, `06-on-demand-test.md`, `07-testcontainers.md`.

## Outstanding manual steps

1. **Re-capture screenshots.** Copied into [`screenshots-to-recapture/`](screenshots-to-recapture/)
   for reference — they bake in the old Spring Initializr UI and can't be regenerated
   programmatically:
   - `initializr-metadata.png`
   - `initializr-dependencies.png`

2. **Verify the hosted Initializr dashboard image.** Lab `01-initializr` uses
   `ghcr.io/vmware-tanzu-labs/educates-spring-initializr:2.0` (pinned in
   `workshops/01-initializr/resources/workshop.yaml`) to let learners generate the
   starting project interactively. Confirm this image can actually generate a Spring
   Boot 4.1 project with the `Cloud Stream` + `Spring for Apache Kafka` dependencies
   before publishing — this is an external dependency outside both repos.

3. **Re-run the Testcontainers e2e test with real Docker access.** Confirm
   `CashCardTransactionStreamE2EContainerTests` passes end-to-end in an environment
   where the Gradle test JVM can reach a Docker daemon (this sandbox couldn't).

4. **Decide the fate of the `main` branches.** Both repos' `main` branches were left
   untouched by design. The code repo's `main`/legacy `cashcard/` directory appears to be
   unused template scaffolding — worth confirming and possibly cleaning up separately,
   but that's out of scope for this upgrade.
