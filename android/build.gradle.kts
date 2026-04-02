// ✅ Fichier build.gradle.kts au niveau PROJET (Kotlin DSL)
buildscript {
    val kotlinVersion by extra("1.9.22")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirection du dossier de build
val buildDir: Directory = rootProject.layout.buildDirectory.get()
subprojects {
    project.layout.buildDirectory.set(buildDir.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
