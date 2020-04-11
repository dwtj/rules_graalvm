package trivial_java_targets;

import static trivial_java_targets.Greeter.greet;

public class Main {
    public static void main(String[] args) {
        String vmName = System.getProperty("java.vm.name");
        greet("java");
        System.out.println("Sincerely, " + vmName + ".");
    }
}