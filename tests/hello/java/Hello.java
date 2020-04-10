package hello.java;

import static hello.java.Greeter.greet;

public class Hello {
    public static void main(String[] args) {
        String vmName = System.getProperty("java.vm.name");
        greet("java");
        System.out.println("Sincerely, " + vmName + ".");
    }
}