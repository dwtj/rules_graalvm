package hello.java;

public class Hello {
    public static void main(String[] args) {
        String vmName = System.getProperty("java.vm.name");
        System.out.println("Hello, Java. From, VM: " + vmName);
    }
}