import com.android.build.api.variant.LibraryAndroidComponentsExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    plugins.withId("com.android.library") {
        if (name == "isar_flutter_libs") {
            val androidExtension = extensions.findByName("android")
            val setNamespace =
                androidExtension?.javaClass?.methods?.firstOrNull {
                    it.name == "setNamespace" && it.parameterCount == 1
                }
            setNamespace?.invoke(androidExtension, "dev.isar.isar_flutter_libs")

            extensions.findByType(LibraryAndroidComponentsExtension::class.java)
                ?.finalizeDsl { ext -> ext.compileSdk = 36 }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
