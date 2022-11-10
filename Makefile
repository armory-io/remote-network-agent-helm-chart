REPORT_DIR := ${PWD}/reports/test

.PHONY: build-dirs
build-dirs:
	@mkdir -p $(REPORT_DIR)

.PHONY: clean
clean:
	rm -fr $(REPORT_DIR)

.PHONY: test
test:
	@echo "Running Helm unittest"
	@docker run -it --rm -v ${HOME}:${HOME} -w ${PWD} \
		quintush/helm-unittest \
		--helm3 \
		--output-file reports/test/results.xml \
		--output-type JUnit . \
		|| echo "TESTS FAILED"

.PHONY: report
report:
	@echo "building html report"
	npx -y xunit-viewer -r reports/test/results.xml -o reports/test/results.html

.PHONY: check
check: clean build-dirs test report
