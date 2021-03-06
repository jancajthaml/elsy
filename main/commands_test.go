package main

import (
	"io/ioutil"
	"reflect"
	"strings"
	"testing"
)

type testCase struct {
	config            string
	expected          []string
	shouldPanic       bool
	expectedErrorText string
}

var testCases = []testCase{
	{"", []string{}, false, ""},
	{"docker_registry: registry", []string{"registry"}, false, ""},
	{"docker_registries: [registry1, test]", []string{"registry1", "test"}, false, ""},
	{"docker_registries: [singletonreg]", []string{"singletonreg"}, false, ""},
	{"docker_registries: \n  - registryb\n  - registryc", []string{"registryb", "registryc"}, false, ""},
	{"docker_registry: registry\ndocker_registries: [registry1, test]", []string{"registry"}, true, "multiple docker registry configs"},
	{"docker_registries: \n  -registryb\n", []string{"registryb"}, true, "but did not find any registries, verify that yaml is correct"},
}

func TestResolveDockerRegistry(t *testing.T) {
	for _, test := range testCases {
		if test.shouldPanic {
			runAssertPanic(t, test)
		} else {
			runAssertNoPanic(t, test)
		}
	}
}

func runAssertPanic(t *testing.T, test testCase) {
	defer func() {
		r := recover()
		if r == nil {
			t.Errorf("The code did not panic, but was supposed to, test case: %v", test)
		} else if !strings.Contains(r.(error).Error(), test.expectedErrorText) {
			t.Errorf("Expected error text to contain %q, but found %q", test.expectedErrorText, r)
		}
	}()
	loadConfig(t, test.config)
	resolveDockerRegistryFromConfig()
}

func runAssertNoPanic(t *testing.T, test testCase) {
	defer func() {
		if r := recover(); r != nil {
			t.Errorf("The code panicked, but was not supposed to. test case: %v, error: %v", test, r)
		}
	}()
	loadConfig(t, test.config)
	if v := resolveDockerRegistryFromConfig(); !reflect.DeepEqual(test.expected, v.Value()) {
		t.Errorf("expected to get %q, but got %q instead", test.expected, v.Value())
	}
}

func loadConfig(t *testing.T, config string) {
	if fh, err := ioutil.TempFile("", "testlcconfigyaml"); err != nil {
		t.Fatal("could not create temporary file")
	} else {
		defer fh.Close()
		fh.WriteString(config)
		LoadConfigFile(fh.Name())
	}
}
