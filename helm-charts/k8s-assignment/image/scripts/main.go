package main

import (
"context"
"fmt"
"log"
"os"
"time"

corev1 "k8s.io/api/core/v1"
metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
"k8s.io/apimachinery/pkg/fields"
"k8s.io/apimachinery/pkg/watch"
"k8s.io/client-go/kubernetes"
"k8s.io/client-go/rest"
"k8s.io/client-go/tools/clientcmd"
)

func main() {
log.Println("Starting Kubernetes Pod Watcher...")

// Get Kubernetes client
client, err := getKubernetesClient()
if err != nil {
log.Fatalf("Failed to create Kubernetes client: %v", err)
}

// Watch pods in k8s-assignment namespace
watchPods(client)
}

func getKubernetesClient() (*kubernetes.Clientset, error) {
// Try in-cluster config first (if running inside cluster)
config, err := rest.InClusterConfig()
if err != nil {
// Fall back to kubeconfig file (for local development)
kubeconfig := os.Getenv("KUBECONFIG")
if kubeconfig == "" {
kubeconfig = os.Getenv("HOME") + "/.kube/config"
}
config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
if err != nil {
return nil, fmt.Errorf("failed to build config: %v", err)
}
}

clientset, err := kubernetes.NewForConfig(config)
if err != nil {
return nil, fmt.Errorf("failed to create clientset: %v", err)
}

return clientset, nil
}

func watchPods(client *kubernetes.Clientset) {
namespace := os.Getenv("NAMESPACE")
if namespace == "" {
namespace = "k8s-assignment" // Default fallback
}

log.Printf("Watching pods in namespace: %s", namespace)

for {
// Create a watcher for pods
watcher, err := client.CoreV1().Pods(namespace).Watch(context.TODO(), metav1.ListOptions{
FieldSelector: fields.Everything().String(),
})
if err != nil {
log.Printf("Error creating watcher: %v", err)
time.Sleep(5 * time.Second)
continue
}

// Process events
for event := range watcher.ResultChan() {
pod, ok := event.Object.(*corev1.Pod)
if !ok {
continue
}

timestamp := time.Now().Format("2006-01-02 15:04:05")

switch event.Type {
case watch.Added:
log.Printf("[%s] Pod CREATED: %s in namespace %s", timestamp, pod.Name, pod.Namespace)
case watch.Deleted:
log.Printf("[%s] Pod DELETED: %s in namespace %s", timestamp, pod.Name, pod.Namespace)
case watch.Modified:
log.Printf("[%s] Pod UPDATED: %s in namespace %s", timestamp, pod.Name, pod.Namespace)
}
}

log.Println("Watcher closed, reconnecting...")
time.Sleep(2 * time.Second)
}
}
