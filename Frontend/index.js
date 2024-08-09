// Function to fetch and display resume data
async function displayResume() {
    try {
        // Fetch the JSON data
        const response = await fetch('https://ms5s1hpxfc.execute-api.us-west-2.amazonaws.com/dev-stage/');

        // Check if the response is successful
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        // Destructure the data from the first element of the array
        const { basics, education, languages, projects, certificates, skills } = data[0];

        // Initialize HTML content
        let htmlContent = '';

        // Personal Information Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h1 class="text-3xl font-bold text-gray-900">${basics.name || ''}</h1>
            <p class="text-lg font-light text-gray-800">${basics.label || ''}</p>
            <p class="text-md font-light text-gray-800">${basics.email || ''}</p>
            <p class="text-md font-light text-gray-800">${basics.phone || ''}</p>
            <p class="text-md font-light text-gray-800">${basics.location?.city || ''}, ${basics.location?.countryCode || ''}</p>
        </section>`;

        // Education Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h2 class="text-2xl mb-3 font-bold uppercase text-gray-900">
                <i class="fa-solid fa-graduation-cap"></i> Education
                <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
            </h2>`;

        // Append each education entry
        education.forEach(edu => {
            htmlContent += `
            <div class="flex mb-4 justify-between">
                <div class="">
                    <h2 class="text-lg mb-1 font-medium text-gray-800">${edu.area}</h2>
                    <p class="font-light text-md italic text-gray-900">${edu.institution}</p>
                </div>
                <p class="text-md font-light text-gray-800 italic">
                    <span class="text-violet-800">${edu.startDate} - ${edu.endDate}</span>
                </p>
            </div>`;
        });

        htmlContent += `</section>`;

        // Skills Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                <i class="fa-solid fa-gears"></i> Skills
                <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
            </h2>
            <ul class="grid grid-cols-2 gap-2 list-disc list-inside marker:text-violet-500">`;

        // Append each skill
        skills.forEach(skill => {
            htmlContent += `<li class="border-2 border-violet-50 text-lg font-light text-slate-900 p-2 rounded-lg">${skill.name}</li>`;
        });

        htmlContent += `</ul>
        </section>`;

        // Certifications Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                <i class="fa-solid fa-certificate"></i> Certifications
                <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
            </h2>`;

        // Append each certification
        certificates.forEach(cert => {
            htmlContent += `<p class="font-light text-md italic text-gray-900"><a href="${cert.url}" target="_blank">${cert.name}</a></p>`;
        });

        htmlContent += `</section>`;

        // Languages Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                <i class="fa-solid fa-language"></i> Languages
                <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
            </h2>
            <ul class="grid grid-cols-2 gap-2 list-disc list-inside marker:text-violet-500">`;

        // Append each language
        languages.forEach(language => {
            htmlContent += `<li class="border-2 border-violet-50 text-lg font-light text-slate-900 p-2 rounded-lg">${language.language} (${language.Proficiency})</li>`;
        });

        htmlContent += `</ul>
        </section>`;

        // Projects Section
        htmlContent += `
        <section class="bg-white px-8 py-4">
            <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                <i class="fa-solid fa-briefcase"></i> Projects
                <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
            </h2>`;

        // Append each project
        projects.forEach(project => {
            htmlContent += `
            <div class="mb-4">
                <h3 class="text-lg font-medium text-gray-800">${project.name}</h3>
                <p class="text-md font-light text-gray-900">${project.description}</p>
                <p class="text-md font-light text-gray-800 italic">
                    <span class="text-violet-800">${project.startDate} - ${project.endDate}</span>
                </p>
                <a href="${project.url}" class="text-violet-500" target="_blank">${project.url}</a>
            </div>`;
        });

        htmlContent += `</section>`;

        // Inject the generated HTML into the DOM
        document.getElementById('resumeContainer').innerHTML = htmlContent;

    } catch (error) {
        console.error('Error fetching the JSON data:', error);
        document.getElementById('resumeContainer').innerHTML = `<p class="text-red-500 text-center">Failed to load resume data.</p>`;
    }
}

// Call the function to display the resume
displayResume();
